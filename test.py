import paho.mqtt.client as mqtt
import threading
from random import uniform
import time

mqttBroker = "192.168.1.88"
mqttPort = 1883

def simulate_device(i):
    client = mqtt.Client(
        client_id=f'Temperature_Device_{i}',
        protocol=mqtt.MQTTv311,
        callback_api_version=mqtt.CallbackAPIVersion.VERSION2
    )
    client.connect(mqttBroker, mqttPort)
    while True:
        randNumber = uniform(20, 31)
        payload = f"Device {i}: {randNumber}"
        client.publish(f"TEMPERATURE", payload)
        print(f"Device {i}: {randNumber:.2f}")
        time.sleep(uniform(2,5))

for i in range(1, 301):  # Try 100 first, not 5000
    
    if(i % 70 == 0):
        time.sleep(0.2)

    threading.Thread(target=simulate_device, args=(i,), daemon=True).start()

while True:
    time.sleep(10)
