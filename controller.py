from flask import Flask, redirect, url_for, render_template 
import numpy as np  
import pandas as pd 
import folium
import mysql.connector

app = Flask(__name__)

@app.route("/")
def home():
	
	#create connection
	dbcon = mysql.connector.connect(
	    host='localhost',
	    user='root',
	    passwd='F!r3m@n8',
	    db='nig_covid'
	)

	df = pd.read_sql('SELECT * from nig_state_affected',con=dbcon)

	# Nigeria latitude and longitude values
	latitude = 9.0820
	longitude = 8.6753

	nigeria_map = folium.Map(location=[latitude, longitude], zoom_start=6)

	# instantiate a feature group for the incidents in the dataframe
	affectedAreas = folium.map.FeatureGroup()

	# loop through the 35 states and add each to the incidents feature group
	for lat, lng, in zip(df.Y, df.X):
	    affectedAreas.add_child(
	        folium.CircleMarker(
	            [lat, lng],
	            radius=5, # define how big you want the circle markers to be
	            color='yellow',
	            fill=True,
	            fill_color='blue',
	            fill_opacity=0.6
	        )
	    )
	    
	# add pop-up text to each marker on the map
	latitudes = list(df.Y)
	longitudes = list(df.X)
	labels = list(df.state)
	labels2 = list(df.confirm_cases)

	for lat, lng, label, label2 in zip(latitudes, longitudes, labels, labels2):
	    folium.Marker([lat, lng], popup=label).add_to(nigeria_map)
	    
	# add incidents to map
	nigeria_map.add_child(affectedAreas)
	nigeria_map.save('templates/map.html')

	# sum of confirmed cases
	totalCase = df['confirm_cases'].sum()

	# Active cases
	activeCase = df['on_admission'].sum()

	# Discharged cases
	dischargedCase = df['discharged'].sum()

	# Death cases
	deathcase = df['deaths'].sum()

	return render_template("index.html", totalCase=totalCase, activeCase=activeCase, dischargedCase=dischargedCase, deathcase=deathcase)


if __name__ == "__main__":
	app.run(debug=True)