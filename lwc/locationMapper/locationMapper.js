import {LightningElement, track, api, wire} from 'lwc';
import LEAFLET_MAPS from  '@salesforce/resourceUrl/leaflet';
import { CurrentPageReference } from 'lightning/navigation';
import { registerListener, unregisterAllListeners } from 'c/pubSub';
import {loadScript, loadStyle} from "lightning/platformResourceLoader";
// const LEAFLET_ACCESS_TOKEN = 'pk.eyJ1IjoibWFnZ2lveGc5IiwiYSI6ImNqdTh2NjIyNzI5N2U0OXIxOTFqa2x4ZmUifQ.xlLFqcZ94YcLxSJQir_4uA';
const C3LLC_LEAFLET_ACCESS_TOKEN = 'pk.eyJ1Ijoicm5lbmR6YSIsImEiOiJjazY2bmJjd3Ixbmh0M2xxbzcwOW9sNDE2In0.wfXNY9A_5B7xNorn4z_CaQ';
const LEAFLET_ACCESS_TOKEN = 'pk.eyJ1Ijoicm5lbmR6YSIsImEiOiJjazY2bmJjd3Ixbmh0M2xxbzcwOW9sNDE2In0.wfXNY9A_5B7xNorn4z_CaQ';

export default class LocationMapper extends LightningElement {

    _hasRendered = false;
    _leafletLoaded = false;
    _map;
    _userCurrentPosition;

    @track businesses = [];
    @track selectedLocation = '';
    @track selectedGeoAddress = null;
    @track selectedTerm = '';
    @track selectedCategory = '';

    @wire(CurrentPageReference) pageRef;
    @api
    get cardTitle() {
        if(this.selectedLocation) {
            return this.selectedLocation;
        } else {
            return 'Location Mapper';
        }
    }

    constructor() {
        super();
        this.isSearching = true;
        this.getUsersCurrentPosition();
    }
    connectedCallback() {
        this.isSearching = true;
        this.registerListeners();
    }
    renderedCallback() {
        if(!this._hasRendered) {
            this._hasRendered = true;
            this.loadLeafletAndFa();
        }
    }
    /**
     * Grab the div element... init the leaflet map.  download the tile layers.
     * Set the map center point, register map click handlers, add some sample markers.
     */
    initMap() {
        const eMapDiv = this.template.querySelector('.accel-leaflet-map');
        try {
            L.Map = L.Map.extend({
                openPopup: function(popup) {
                    //        this.closePopup();  // just comment this
                    this._popup = popup;

                    return this.addLayer(popup).fire('popupopen', {
                        popup: this._popup
                    });
                }
            }); /***  end of hack ***/

            if(this._map) {
                this._map.eachLayer(function(layer){
                    layer.remove();
                });
                this._map.remove();
                this._map = null;
            }
            let map = L.map(eMapDiv);
            this._map = map;
            let accessToken = LEAFLET_ACCESS_TOKEN;

            // var mbAttr = 'Map data &copy; <a href="https://www.openstreetmap.org/">OpenStreetMap</a> contributors, ' +
            //     '<a href="https://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, ' +
            //     'Imagery © <a href="https://www.mapbox.com/">Mapbox</a>',
            //     mbUrl = 'https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token='+accessToken;

            L.tileLayer('https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token='+accessToken, {
                attribution: 'Map data &copy; <a href="https://www.openstreetmap.org/">' +
                    'OpenStreetMap</a> contributors, <a href="https://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, ' +
                    'Imagery © <a href="https://www.mapbox.com/">Mapbox</a>',
                maxZoom: 18,
                minZoom: 4,
                id: 'mapbox/streets-v11',
                opacity: 1.5,
                accessToken: accessToken
            }).addTo(map);

            // var grayscale   = L.tileLayer(mbUrl, {id: 'mapbox/light-v9', attribution: mbAttr}),
            //     streets  = L.tileLayer(mbUrl, {id: 'mapbox/streets-v11',   attribution: mbAttr});
            //
            // var map = L.map('map', {
            //     center: [39.73, -104.99],
            //     zoom: 10,
            //     layers: [grayscale, cities]
            // });
            //
            // var baseLayers = {
            //     "Grayscale": grayscale,
            //     "Streets": streets
            // };
            //
            // var overlays = {
            //     "Cities": cities
            // };
            //
            // L.control.layers(baseLayers, overlays).addTo(map);



            this.setMapCenterPoint(map);
            map.on('click',this.onMapClick);
            this.addMapMarkers(map);

            //L.layers()

            // //---- this.addFullScreen(map);
            //  var searchLayer = L.layerGroup().addTo(map);
            //  //... adding data in searchLayer ...
            //  map.addControl( new L.Control.Search({layer: searchLayer}) );
            //searchLayer is a L.LayerGroup contains searched markers
            // var grayscale = L.tileLayer(mbUrl, {id: 'mapbox/light-v9', attribution: mbAttr}),
            //     streets   = L.tileLayer(mbUrl, {id: 'mapbox/streets-v11', attribution: mbAttr});




            console.log('map loaded!');
        } catch (e) {
            alert(e);
        }
    }

    setMapCenterPoint(map) {
        let lat = 41.8781;
        let long = -87.7798;
        if(this.selectedGeoAddress) {
            if(this.selectedGeoAddress.lat) {
                lat = this.selectedGeoAddress.lat;
            }
            if(this.selectedGeoAddress.lon) {
                long = this.selectedGeoAddress.lon;
            }
        } else {
            if (this._userCurrentPosition) {
                let coordinates = this._userCurrentPosition.coords;
                lat = coordinates.latitude;
                long = coordinates.longitude;
            }
        }
        let circle = L.circle([lat, long], {
            color: 'red',
            fillColor: '#f03',
            fillOpacity: 0.1,
            radius: 16000
        }).addTo(map);
        let rZoom = 10;
        let marker = L.marker([lat,long]);//.addTo(map);
        let toolTip = 'Location Searched - '+this.selectedLocation;
        marker.bindTooltip(toolTip, {direction: 'top', offset: [0,-30]});
        marker.bindPopup("<b>Location Searched</b><br> loc here.").openPopup();
        marker.addTo(map);
        map.setView([lat,long], rZoom);
    }
    addMapMarkers(map) {
        //marker fun experimentation
        //let marker = L.marker([41.8, -87.62]).addTo(map);
        // let circle = L.circle([41.508, -87.11], {
        //     color: 'red',
        //     fillColor: '#f03',
        //     fillOpacity: 0.5,
        //     radius: 500
        // }).addTo(map);
        //
        // let polygon = L.polygon([
        //     [42.509, -86.08],
        //     [43.503, -86.06],
        //     [45.51, -86.047]
        // ]).addTo(map);
    }
    bindMapPopups(map) {
        marker.bindPopup("<b>Hello world!</b><br>I am a popup.").openPopup();
        circle.bindPopup("I am a circle.");
        polygon.bindPopup("I am a polygon.");
    }
    onMapClick(e) {
        //alert("You clicked the map at " + e.latlng);
    }
    handleLocationListUpdate(businesses) {
        this.businesses = businesses;
        this.parseBusinessInfo();
    }
    handleLocationSelected(locationSelected) {
        this.selectedGeoAddress = locationSelected;
        if(this.selectedGeoAddress) {
            this.selectedLocation = this.selectedGeoAddress.display_address;
        }
        this.initMap();
    }
    handleIsSearching(searching) {
        this.isSearching = searching;
    }
    handleCategoriesSelected(categoriesSelected) {
        if(categoriesSelected && Array.isArray(categoriesSelected) && categoriesSelected.length > 0) {
            this.selectedCategory = categoriesSelected[0];
        }
    }
    handleTermModified(term) {
        this.selectedTerm = term;
    }
    parseBusinessInfo() {
        if(this.businesses && Array.isArray(this.businesses) && this.businesses.length > 0) {
            console.log('-------> parseBusinessInfo ----- length='+this.businesses.length);
            let idx = 1;
            this.businesses.forEach(x =>  {
                console.log(JSON.stringify(x));
                this.addRealMapMarker(x,idx);
                idx++;
            });
        }
    }
    addRealMapMarker(business,idx) {
        if(business.idx === 1) {
            JSON.stringify(business);
        }
        let map = this._map;
        let coordinates = business.coordinates;
        console.log('---- business coordinates-'+JSON.stringify(coordinates));
        let lat = coordinates.latitude;
        let long = coordinates.longitude;
        console.log(coordinates);
        let html = "<div style='background-color:#4838cc;' class='marker-pin'></div><i class='awesome'><span style='font-weight:bold'>"+business.idx+"</span>";
        const fontAwesomeIcon = L.divIcon({
            className: 'custom-div-icon',
            html: html,
            iconSize: [30, 42],
            iconAnchor: [15, 42]
        });
        let marker = L.marker([lat,long],{ icon:  fontAwesomeIcon});
        marker.on('click', function(e){
            map.setView(e.latlng, 14);
        });
        let toolTip =  '<b>'+business.name+'</b>' + '<br/>'+business.location.display_address;
        marker.bindTooltip(toolTip, {direction: 'top', offset: [0,-30]});
        marker.addTo(map);
    }

    /**
     * Loads leaflet js and css for fonts not available in SLDS.
     * @todo only load what is needed. we are probably loading too much here.
     */
    loadLeafletAndFa() {
        Promise.all([
            loadStyle(this, LEAFLET_MAPS + '/leaflet.css'),
            loadScript(this, LEAFLET_MAPS + '/leaflet.js')
            // loadStyle(this, LEAFLET_SEARCH + '/src/leaflet-search.css'),
            // loadScript(this, LEAFLET_SEARCH + '/src/leaflet-search.js')

        ])
            .then(() => {
                console.log('all leaflet resources loaded');
                this._leafletLoaded = true;
                this.initMap();
            })
            .catch(error => {
                console.error(error);
                alert('error eloading libs:'+JSON.stringify(error));
                //console.error(error;
            });
    }
    registerListeners() {
        registerListener('locationListUpdate', this.handleLocationListUpdate, this);
        registerListener('locationSelected', this.handleLocationSelected, this);
        registerListener('categoriesSelected', this.handleCategoriesSelected, this);
        registerListener('termModified', this.handleTermModified, this);
        registerListener('isSearching', this.handleIsSearching, this);
    }
    getUsersCurrentPosition() {
        navigator.geolocation.getCurrentPosition(position => {
            var crd = position.coords;
            console.log('Your current position is:');
            console.log('Latitude : '+crd.latitude);
            console.log(crd);
            this._userCurrentPosition = position;
        });
    }
}