public class YelpSearchSvc {

    public static String FUSION_API_ENDPOINT    = 'https://api.yelp.com';
    public static STring FUSION_API_VERSION     = '/v3';
    public static String LOCATION_IQ_API_KEY    = '3dfe0256c39a6d';
    public static String LOCATION_IQ_ENDPOINT   = 'https://api.locationiq.com/v1/autocomplete.php';
    public static String LOCATION_IQ_REVERSE_GEOCODE_ENDPOINT = 'https://us1.locationiq.com/v1/reverse.php';
    public static String CLIENT_ID              = 'cLapdw9xeDuriwphz2jwyg';
    public static String API_KEY                = 'ORwnxEX7vePnlaeuhSHAgXnTYWpKPOwJoUBSFaNERmAxJ4cHOX1YkKaFlvscAo5YpGtZvkdViyjtFcBb-5mBwcC0XAVuW7Mpd2UzLCsGnuKYXzEl89EhYwtqDWc0XnYx';
    public static String SEARCH_PATH            =  '/search';
    public static String BUSINESS_PATH          =  '/businesses';
    public static String CATEGORIES_PATH        =  '/categories';


    public static String reverseGeocode(Decimal latitude, Decimal longitude) {
        String responseBody = '';
        String ep = LOCATION_IQ_REVERSE_GEOCODE_ENDPOINT + '?key=' + LOCATION_IQ_API_KEY;
        ep  +='&lat='+latitude;
        ep  +='&lon='+longitude;
        ep  +='&format=JSON';
        HttpRequest req = buildRequest(ep);

        Http http = new Http();
        HttpResponse response = http.send(req);

        switch on response.getStatusCode() {
            when 200 {
                responseBody = response.getBody(); //this is already consumable JSON
            }
            when else {
                System.debug(LoggingLevel.ERROR, response.getStatusCode() + response.getStatus());
            }
        }
        return responseBody;
    }


    public static String autocompleteLocationIq( String text) {
        String responseBody = '';
        String ep = LOCATION_IQ_ENDPOINT + '?key=' + LOCATION_IQ_API_KEY + '&q=';
        ep  += text;
        ep  +='&countrycodes=us';
        HttpRequest req = buildRequest(ep);

        Http http = new Http();
        HttpResponse response = http.send(req);

        switch on response.getStatusCode() {
            when 200 {
                responseBody = response.getBody(); //this is already consumable JSON
            }
            when else {
                System.debug(LoggingLevel.ERROR, response.getStatusCode() + response.getStatus());
            }
        }
        return responseBody;
    }
    /**
     *
     * @param location
     * @param term
     *
     * @return
     */
    public static String businessSearch(  String location, Decimal latitude, Decimal longitude,
            String term, String sCategories, Integer radiusMeters) {
        String jsonResult;

        String responseBody = '';
        String ep = FUSION_API_ENDPOINT + FUSION_API_VERSION + BUSINESS_PATH + SEARCH_PATH;

        if(latitude != null && longitude != null) {
            ep  += '?latitude='+latitude + '&longitude='+longitude;
        } else {
            ep += '?location=' + location;
        }
        ep += '&term='+term;
        if(sCategories != null && sCategories != '') {
            ep += '&categories='+sCategories;
        }
        ep += '&radius='+radiusMeters;
        ep += '&sort_by=distance&limit=50';

        HttpRequest req = buildRequest(ep);
        Http http = new Http();
        HttpResponse response = http.send(req);

        switch on response.getStatusCode() {
            when 200 {
                responseBody = response.getBody();
                System.debug(responseBody);
                jsonResult = responseBody;
            }
            when else {
                System.debug(LoggingLevel.ERROR, response.getStatusCode() + response.getStatus());
            }
        }
        //return parseResult;
        return jsonResult;
    }
    public static String businessDetailsSearch( String businessId ) {

        String responseBody = '';
        String ep = FUSION_API_ENDPOINT + FUSION_API_VERSION + BUSINESS_PATH  + '/';
        ep  += businessId;
        HttpRequest req = buildRequest(ep);
        Http http = new Http();
        HttpResponse response = http.send(req);

        switch on response.getStatusCode() {
            when 200 {
                responseBody = response.getBody();
            }
            when else {
                System.debug(LoggingLevel.ERROR, response.getStatusCode() + response.getStatus());
            }
        }
        //return parseResult;
        return responseBody;
    }
    /**
     *
     *
     * @param businessId
     * @return
     */
    public static YelpReviewsParser reviewsSearch( String businessId ) {
        YelpReviewsParser parseResult;

        String responseBody = '';
        String ep = FUSION_API_ENDPOINT + FUSION_API_VERSION + BUSINESS_PATH  + '/';
        ep  += businessId   +'/reviews' ;
        HttpRequest req = buildRequest(ep);
        Http http = new Http();
        HttpResponse response = http.send(req);

        switch on response.getStatusCode() {
            when 200 {
                responseBody = response.getBody();
                System.debug(responseBody);
                parseResult = YelpReviewsParser.parse(responseBody);
            }
            when else {
                System.debug(LoggingLevel.ERROR, response.getStatusCode() + response.getStatus());
            }
        }
        return parseResult;
    }
    /**
     *
     * @param locale
     * @return
     */
    public static YelpCategoryParser allCategoriesSearch( String locale) {
        YelpCategoryParser parseResult;

        String responseBody = '';
        String ep = FUSION_API_ENDPOINT + FUSION_API_VERSION + CATEGORIES_PATH;
        ep  += '?locale='+locale;

        HttpRequest req = buildRequest(ep);
        Http http = new Http();
        HttpResponse response = http.send(req);

        switch on response.getStatusCode() {
            when 200 {
                responseBody = response.getBody();
                System.debug(responseBody);
                parseResult = YelpCategoryParser.parse(responseBody);
            }
            when else {
                System.debug(LoggingLevel.ERROR, response.getStatusCode() + response.getStatus());
            }
        }
        return parseResult;
    }
    /**
  *
  * @param locale
  * @return
  */
    public static List<YelpCategoryParser.categories> filteredCategoriesSearch( String locale, Set<String> parentAliases) {
        List<YelpCategoryParser.categories> categories = new List<YelpCategoryParser.categories>();
        YelpCategoryParser results = allCategoriesSearch(locale);
        YelpCategoryParser.Categories category = new YelpCategoryParser.Categories();
        category.title = 'All';
        category.alias = 'All';
        categories.add(category);
        for(YelpCategoryParser.categories result : results.categories) {
            if(result.parent_aliases != null && !result.parent_aliases.isEmpty()) {
                for(String parentAlias : result.parent_aliases) {
                    if(parentAliases.contains(parentAlias)) {
                        categories.add(result);
                    }
                }
            }
        }
        return categories;
    }
    /**
     *
     *
     * @param ep
     *
     * @return
     */
    public static HttpRequest buildRequest(String ep) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(ep);
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('accept', 'application/json');
        req.setHeader('Authorization', 'Bearer '+ API_KEY);
        return req;
    }
}