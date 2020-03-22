public with sharing class YelpCategoryParser {

    @AuraEnabled public List<Categories> categories;

    public class Categories {
        @AuraEnabled public String alias;
        @AuraEnabled public String title;
        @AuraEnabled public List<String> parent_aliases;
        @AuraEnabled public List<String> country_whitelist;
        @AuraEnabled public List<String> country_blacklist;
    }

    public static YelpCategoryParser parse(String json) {
        return (YelpCategoryParser) System.JSON.deserialize(json, YelpCategoryParser.class);
    }
}