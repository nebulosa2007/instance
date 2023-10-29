#!/usr/bin/env python3

from json import load, loads, dump
from glob import glob
from datetime import datetime
from os import popen


def wg_json_traffic_stat_data(wg_ui_path):
    try:
        return loads(popen(wg_ui_path + 'wg-json').read())
    except FileNotFoundError:
        raise

def wg_json_traffic_stat_generator(wg_interface, wg_ui_path, wg_json_path):
    wg_json = wg_json_traffic_stat_data(wg_json_path)
    clients = []
    clients_files = [_ for _ in glob(wg_ui_path + "*.json")]
    clients_id = [_.split("/")[-1].replace(".json", "") for _ in clients_files]

    for _ in range(len(clients_files)):
        with open(clients_files[_], "r") as data_client:
            clients.append(load(data_client))
    for _ in range(len(clients_id)):
        client = clients[_]
        try:
            with open(wg_ui_path + clients_id[_] + "_stat.json", "r") as stat_id_file:
                for_stat_file = load(stat_id_file)
                tstat = list(for_stat_file[client['public_key']]['tstat'])
        except:
            tstat = []
        try:
            transferRx = wg_json[wg_interface]['peers'][client['public_key']]['transferRx']
            transferTx = wg_json[wg_interface]['peers'][client['public_key']]['transferTx']
            instant_traffic = {datetime.now().strftime("%Y-%m-%d"): {'transferRx': transferRx, 'transferTx': transferRx}}
        except:
            instant_traffic = ''
        if instant_traffic:
            tstat.append(instant_traffic)
        for_stat_file = {client['public_key']: {"name": client['name'], "tstat": tstat}}
        try:
            with open(wg_ui_path + clients_id[_] + "_stat.json", "w") as stat_id_file:
                dump(for_stat_file, stat_id_file, indent=7)
        except:
            print(f'Problem with {clients_id[_] + "_stat.json"} file! Check file write permission')


if __name__ == "__main__":
    wg_interface = "wg0"
    wg_ui_path   = "/opt/wireguard-ui/db/clients/"
    wg_json_path = "/usr/share/wireguard-tools/examples/json/"

    wg_json_traffic_stat_generator(wg_interface, wg_ui_path, wg_json_path)
