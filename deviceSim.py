import os
import requests
import time

# In the final working version, this code would live on the raspberry pi, and these values
# would be obtained from the app on setup
# I'm hardcoding them here
name = 'Ryan'
# channel url will have to have some UUID code added later for guaranteed uniqueness
channel_url = "Ryan_distress"
# should change to private for security. Not now because requires communication between devices
is_public = True
# create phone as user and script as user
user_ids = [name]
invitation_status = {
	name: "joined",
}

api_headers = {
	'Api-Token': '85fb79109f4347b9b182690103e229475378c4f6'
}

data = {
    'name': 'Ryan_Test',
    'channel_url': channel_url,
    'is_public': is_public,
    'user_ids': user_ids,
}

# look for channel
res = requests.get("https://api.sendbird.com/v3/group_channels/" + channel_url, headers=api_headers)

# if there is no channel
if res.status_code != 200:
	# create channel
	res = requests.post('https://api.sendbird.com/v3/group_channels', 
	    headers=api_headers, 
	    json=data)
	print(res)

# Post an admin message
data = {
	'message_type': 'ADMM',
	'message': 'Your car was broken into at ' + str(time.strftime('%Y-%m-%d %H:%M:%S ', time.localtime())),
	'send_push': True,
	'mention_type': 'channel'
}

res = requests.post("https://api.sendbird.com/v3/group_channels/" + channel_url + "/messages",
	headers=api_headers,
	json=data)
# Now read the message
if res.status_code == 200:
	message_id = res.json()['message_id']
	res = requests.get("https://api.sendbird.com/v3/group_channels/"+ channel_url + "/messages/" + str(message_id),
		headers=api_headers)
	print(res.json()['message'])
else:
	# print the error
	print(res.json())


