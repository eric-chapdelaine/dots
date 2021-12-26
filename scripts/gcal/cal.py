from __future__ import print_function
import datetime
import pickle
import os.path
import sys
from googleapiclient.discovery import build
from google_auth_oauthlib.flow import InstalledAppFlow
from google.auth.transport.requests import Request

from dateutil.parser import parse

SCOPES = ['https://www.googleapis.com/auth/calendar.readonly']

def main():
    """
    Prints the next 1 event on the user's calendar
    """
    creds = None

    if os.path.exists('token.pickle'):
        with open('token.pickle', 'rb') as token:
            creds  = pickle.load(token)

    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            flow = InstalledAppFlow.from_client_secrets_file(
                    'credentials.json', SCOPES)
            creds = flow.run_local_server(port=0)

        with open('token.pickle', 'wb') as token:
            pickle.dump(creds, token)

    service = build('calendar', 'v3', credentials=creds)

    # Call the actual API
    gNow = datetime.datetime.utcnow().isoformat() + 'Z' # 'Z' is to indicate UTC time
    #print('Getting the next 10 events')
    # kr3suerpvq6uj6fcfjrhq4pd5s@group.calendar.google.com
    # emchap4@gmail.com
    events_result = service.events().list(calendarId=sys.argv[1], timeMin=gNow,
                                        maxResults=1, singleEvents=True,
                                        orderBy='startTime').execute()
    events = events_result.get('items', [])

    if not events:
        print('Nothing scheduled for today')

    # For every event
    # Not useful for just one Result, but could be used in the future
    now = datetime.datetime.now()
    for event in events:
        start = parse(event['start'].get('dateTime', event['start'].get('date'))).replace(tzinfo=None)
        end = parse(event['end'].get('dateTime', event['end'].get('date'))).replace(tzinfo=None)
        if now > start and now < end: 
            time = str(end - now).split(':')
            readable = end.strftime("%I:%M %p")
            print(event['summary'], "ends in", time[0]+":"+time[1], "("+readable+")")
        else:
            time = str(start - now).split(':')
            readable = start.strftime("%I:%M %p")
            print(event['summary'], "starts in", time[0]+":"+time[1], "("+readable+")")
    
    #print(datetime.datetime.now())


if __name__ == '__main__':
    os.chdir(sys.path[0])
    try: 
        main()
    except:
        print("--")
