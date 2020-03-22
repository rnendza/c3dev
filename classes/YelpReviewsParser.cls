public class YelpReviewsParser {

    public class User {
        @AuraEnabled public String id;
        @AuraEnabled public String profile_url;
        @AuraEnabled public String image_url;
        @AuraEnabled public String name;
    }

    public class Reviews {
        @AuraEnabled public String id;
        @AuraEnabled public Integer rating;
        @AuraEnabled public User user;
        @AuraEnabled public String text;
        @AuraEnabled public String time_created;
        @AuraEnabled public String url;
    }

    @AuraEnabled public List<Reviews> reviews;
    @AuraEnabled public Integer total;
    @AuraEnabled public Integer getTotalDisplayedCount() {
        Integer count = 0;
        if(this.reviews != null && !this.reviews.isEmpty()) {
            count =  this.reviews.size();
        }
        return count;
    }

    @AuraEnabled public List<String> possible_languages;

    public class User_Z {
        @AuraEnabled public String id;
        @AuraEnabled public String profile_url;
        @AuraEnabled public Object image_url;
        @AuraEnabled public String name;
    }

    public static YelpReviewsParser parse(String json) {
        return (YelpReviewsParser) System.JSON.deserialize(json, YelpReviewsParser.class);
    }
}