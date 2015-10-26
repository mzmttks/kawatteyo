import requests

host = "http://localhost:08080"
channelid = requests.get(host + "/channels")
print channelid
print channelid.text

print "POST"
clientid = requests.post(host + "/channels/" + channelid.text,
                         {"username": "test"})
print clientid
