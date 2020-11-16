import requests
from bs4 import BeautifulSoup
import pandas as pd
from tqdm import tqdm

def get_player_statistics(event_id="8896868",home=True):
    URL = 'https://api.sofascore.com/api/v1/event/'+str(event_id)+'/lineups'
    headers = {'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.95 Safari/537.36'}
    page = requests.get(URL,headers=headers)
    stats = eval(page.content.decode('utf8').replace("'", '').replace("true","True").replace("false","False"))
    
    home_players = [process_player_statictcs(player) for player in stats["home"]["players"]]
    home_players = [x for x in home_players if x!=None]
    away_players = [process_player_statictcs(player) for player in stats["away"]["players"]]
    away_players = [x for x in away_players if x!=None]
    
    
    return home_players+away_players

def process_player_statictcs(player):
    if player["substitute"]==True:
        return None
    data = {}
    data["name"] = player["player"]["name"]
    data["position"] = player["position"]
    data["rating"] = player["statistics"]["rating"]
    
    return data

#2019-2020 23776
#2020-2021 29415
def get_matches(kolo,season_id):
    URL = 'https://api.sofascore.com/api/v1/unique-tournament/17/season/'+str(season_id)+'/events/round/'+str(kolo)
    headers = {'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.95 Safari/537.36'}
    page = requests.get(URL,headers=headers)
    rezultati = eval(page.content.decode('utf8').replace("'", '"').replace("true","True").replace("false","False"))
    return rezultati

def process_match(match):
    try:
        data = {}
        data["event_id"] = match["id"]

        data["homeTeam"] = match["homeTeam"]["name"]
        data["awayTeam"] = match["awayTeam"]["name"]

        data["homeGoals"] = match["homeScore"]["current"]
        data["awayGoals"] = match["awayScore"]["current"]

        stats = get_player_statistics(match["id"])
        if stats == None:
            return None
        for p in range(11):
            data["h_player_"+str(p)] = stats[p]["name"]
            data["h_position_"+str(p)] = stats[p]["position"]
            data["h_score_"+str(p)] = stats[p]["rating"]
        for p in range(11,22):
            data["a_player_"+str(p)] = stats[p]["name"]
            data["a_position_"+str(p)] = stats[p]["position"]
            data["a_score_"+str(p)] = stats[p]["rating"]
        return data
    except KeyError:
        return None

cijela_liga = []
#2019-2020 23776
#2020-2021 29415
for i in tqdm(range(38)):
    cijelo_kolo = [process_match(match) for match in get_matches(i+1,23776)["events"]]
    cijelo_kolo = [x for x in cijelo_kolo if x!=None]
    cijela_liga+=cijelo_kolo
for i in tqdm(range(8)):
    cijelo_kolo = [process_match(match) for match in get_matches(i+1,29415)["events"]]
    cijelo_kolo = [x for x in cijelo_kolo if x!=None]
    cijela_liga+=cijelo_kolo

df = pd.DataFrame(cijela_liga)
print(df.head())

df.to_csv("PL20192020.csv",index=False)