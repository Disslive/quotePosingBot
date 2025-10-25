public without sharing class TwitterIntegration {
    public static final String TWITTER_API_URL = 'callout:Twitter_API';
    private static String API_KEY;
    private static String REFRESH_KEY;

    public static String getToken() {
        if (String.isEmpty(API_KEY)) {
            Twitter_Keys__c twitterKeys = Twitter_Keys__c.getOrgDefaults();
            API_KEY = twitterKeys.API_Key__c;
            REFRESH_KEY = twitterKeys.Refresh_Key__c;
        }

        return API_KEY;
    }

    public static void refreshToken() {
        System.debug('TweeterIntegration.refreshToken...');
        Twitter_Keys__c twitterKeys = Twitter_Keys__c.getOrgDefaults();

        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:Twitter_API' + '/2/oauth2/token?refresh_token=' + REFRESH_KEY + '&grant_type=refresh_token&client_id=' + twitterKeys.Client_Id__c);
        request.setMethod('POST');

        HttpResponse response = new Http().send(request);
        System.debug('response status code: ' + response.getStatusCode());
        System.debug('response body: ' + response.getBody());

        TwitterDatamodel.Token token = (TwitterDatamodel.Token) JSON.deserialize(response.getBody(), TwitterDatamodel.Token.class);

        API_KEY = token.access_token;
        REFRESH_KEY = token.refresh_token;
    }

    public static HttpResponse uploadFile(Blob pFile) {
        System.debug('TweeterIntegration.uploadFile...');

        if (pFile == null) {
            return null;
        }

        TwitterDatamodel.MediaUploadRequest mediaUploadRequest = new TwitterDatamodel.MediaUploadRequest(pFile);
        HttpRequest request = new HttpRequest();
        request.setEndpoint(TWITTER_API_URL + '/2/media/upload');
        request.setMethod('POST');
        request.setHeader('Authorization', 'Bearer ' + getToken());
        request.setHeader('Content-Type', 'application/json');
        request.setBody(JSON.serialize(mediaUploadRequest));

        HttpResponse response = new Http().send(request);
        
        System.debug('response status code: ' + response.getStatusCode());
        System.debug('response body: ' + response.getBody());

        if (response.getStatusCode() == 401) {
            refreshToken();
            request.setHeader('Authorization', 'Bearer ' + getToken());

            response = new Http().send(request);

            System.debug('response status code: ' + response.getStatusCode());
            System.debug('response body: ' + response.getBody());
        }

        return response;
    }

    public static HttpResponse sendTweet(String pText, List<String> pMediaIdList) {
        System.debug('TweeterIntegration.sendTweet...');

        if (pText == null
                || pMediaIdList == null
                || pMediaIdList.isEmpty()) {
            return null;
        }

        TwitterDatamodel.TweetRequest tweetRequest = new TwitterDatamodel.TweetRequest(pText, pMediaIdList);
        HttpRequest request = new HttpRequest();
        request.setEndpoint(TWITTER_API_URL + '/2/tweets');
        request.setMethod('POST');
        request.setHeader('Authorization', 'Bearer ' + getToken());
        request.setHeader('Content-Type', 'application/json');
        request.setBody(JSON.serialize(tweetRequest));

        HttpResponse response = new Http().send(request);

        System.debug('response status code: ' + response.getStatusCode());
        System.debug('response body: ' + response.getBody());

        if (response.getStatusCode() == 401) {
            refreshToken();
            request.setHeader('Authorization', 'Bearer ' + getToken());
            response = new Http().send(request);

            System.debug('response status code: ' + response.getStatusCode());
            System.debug('response body: ' + response.getBody());
        }

        return response;
    }

    public static void saveToken() {
        Twitter_Keys__c twitterKeys = Twitter_Keys__c.getOrgDefaults();

        if (twitterKeys.API_Key__c != API_KEY || twitterKeys.Refresh_Key__c != REFRESH_KEY) {
            twitterKeys.API_Key__c = API_KEY;
            twitterKeys.Refresh_Key__c = REFRESH_KEY;
            update twitterKeys;
        }
    }
}