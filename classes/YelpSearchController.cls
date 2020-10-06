public with sharing class YelpSearchController {

    public static final String MAP_KEY_BUSINESS_RESULTS         = 'MAP_KEY_BUSINESS_RESULTS';
    public static final String MAP_KEY_BUSINESS_DETAILS         = 'MAP_KEY_BUSINESS_DETAILS';
    public static final String MAP_KEY_FILTERED_CATEGORIES      = 'MAP_KEY_FILTERED_CATEGORIES';

    @AuraEnabled(Cacheable=true)
    public static C3ResponseDto retrieveBusinesses (  String location,
            Decimal latitude, Decimal longitude,
            String term, List<String> categories, Integer radiusMeters ) {
        C3ResponseDto dto = new C3ResponseDto();
        String jsonResult = '';
        String sCategories = null;
        if(categories != null && !categories.isEmpty()) {
            sCategories = String.join(categories,',');
        }
        jsonResult = YelpSearchSvc.businessSearch(location,latitude,longitude,term,sCategories,radiusMeters);
        if(jsonResult != null && jsonResult != '') {
            dto.isSuccess = true;
            dto.message = 'businesses found';
            Object obj = JSON.deserializeUntyped(jsonResult);
            dto.values.put( MAP_KEY_BUSINESS_RESULTS, obj );
        } else {
            dto.technicalMsg = 'invalid search.. location=' + location + '..latitude=' + latitude + '..longitude=' + longitude +
                    '.. term=' + term + '...sCategories=' + sCategories + ' radiusMeters='+radiusMeters;
        }
        return dto;
    }
    /**
     *
     *
     * @param businessId
     * @return
     */
    @AuraEnabled(Cacheable=true)
    public static C3ResponseDto retrieveBusinessDetails ( String businessId ) {
        C3ResponseDto dto = new C3ResponseDto();
        String jsonResult =  YelpSearchSvc.businessDetailsSearch(businessId);
        if(jsonResult!=null) {
            dto.isSuccess = true;
            dto.message = ' businesses details found. ';
            if(jsonResult != '') {
                Object obj = JSON.deserializeUntyped(jsonResult);
                dto.values.put( MAP_KEY_BUSINESS_DETAILS, obj );
            }
        } else {
            dto.technicalMsg = 'invalid search.. businessId='+businessId;
        }
        return dto;
    }
    /**
     *
     * @param businessId
     *
     * @return
     */
    @AuraEnabled(Cacheable=true)
    public static C3ResponseDto retrieveReviews ( String businessId ) {
        C3ResponseDto dto = new C3ResponseDto();
        YelpReviewsParser results = YelpSearchSvc.reviewsSearch(businessId);
        if(results!=null) {
            dto.isSuccess = true;
            dto.message = ' businesses reviews found. ';
            dto.values.put('BLAH', results);
        } else {
            dto.technicalMsg = 'no reviews found.. businessId='+businessId;
        }
        return dto;
    }
    /**
     *
     * @return
     */
    @AuraEnabled(Cacheable=true)
    public static C3ResponseDto retrieveCategories(String locale, List<String> parentAliases) {
        Set<String> uniqueParentCategories = new Set<String>();
        if(parentAliases != null) {
            uniqueParentCategories.addAll(parentAliases);
        }
        C3ResponseDto dto = new C3ResponseDto();
        List<YelpCategoryParser.categories> categories = YelpSearchSvc.filteredCategoriesSearch(locale, uniqueParentCategories);
        dto.isSuccess = true;

        dto.message = categories.size() + ' categories found. ';
        dto.values.put(MAP_KEY_FILTERED_CATEGORIES,categories);
        return dto;
    }
}