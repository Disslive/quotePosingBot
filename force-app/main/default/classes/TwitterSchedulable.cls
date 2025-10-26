public without sharing class TwitterSchedulable implements Schedulable {
    private static final String TWEET_FORMAT = '"{0}" - {1}';
    private static final String NOTIFICATION_EMAIL = Label.Notification_Email;
    private static final String QUOTE = 'quote';
    private static final String IMAGE_GENERATION = 'imageGeneration';
    private static final String MEDIA_UPLOAD = 'mediaUpload';
    private static final String TWEET = 'tweet';
    private static final Map<String, Integer> ACTION_TO_SUCCESS_CODE_MAP = new Map<String, Integer> {
        QUOTE => 200,
        IMAGE_GENERATION => 200,
        MEDIA_UPLOAD => 200,
        TWEET => 201
    };

    public void execute(SchedulableContext sc) {
        sendTweet();
    }

    @future(callout=true)
    private static void sendTweet() {
        Map<String, HttpResponse> actionToResponseMap = new Map<String, HttpResponse>();
        for (String action_i : ACTION_TO_SUCCESS_CODE_MAP.keySet()) {
            Integer statusCode_i = ACTION_TO_SUCCESS_CODE_MAP.get(action_i);
            HttpResponse response_i = getResponse(action_i, actionToResponseMap);
            if (response_i == null || response_i.getStatusCode() != statusCode_i) {
                sendErrorEmail(action_i, response_i == null ? 'Unknown Error.' : response_i.getBody());
                break;
            }
            actionToResponseMap.put(action_i, response_i);
        }
        TwitterIntegration.saveToken();
    }

    private static HttpResponse getResponse(String pAction, Map<String, HttpResponse> pActionToResponseMap) {
        HttpResponse response;
        switch on pAction {
            when 'quote'{
                response = ZenQuoteIntegration.getTodayQuote();
            }
            when 'imageGeneration' {
                List<ZenQuoteDatamodel.ZenQuoteResponse> zenQuoteResponseList = (List<ZenQuoteDatamodel.ZenQuoteResponse>) JSON.deserialize(pActionToResponseMap.get(QUOTE).getBody(), List<ZenQuoteDatamodel.ZenQuoteResponse>.class);
                response = ImageGeneratorIntegration.getImage(zenQuoteResponseList.get(0).a, zenQuoteResponseList.get(0).q);
            }
            when 'mediaUpload' {
                response = TwitterIntegration.uploadFile(pActionToResponseMap.get(IMAGE_GENERATION).getBodyAsBlob());
            }
            when 'tweet' {
                List<ZenQuoteDatamodel.ZenQuoteResponse> zenQuoteResponseList = (List<ZenQuoteDatamodel.ZenQuoteResponse>) JSON.deserialize(pActionToResponseMap.get(QUOTE).getBody(), List<ZenQuoteDatamodel.ZenQuoteResponse>.class);
                TwitterDatamodel.MediaUploadResponse mediaUploadResponse = (TwitterDatamodel.MediaUploadResponse) JSON.deserialize(pActionToResponseMap.get(MEDIA_UPLOAD).getBody(), TwitterDatamodel.MediaUploadResponse.class);
                response = TwitterIntegration.sendTweet(String.format(TWEET_FORMAT, new List<String> {zenQuoteResponseList.get(0).q, zenQuoteResponseList.get(0).a}), new List<String> {mediaUploadResponse.data.id});
            }
        }
        return response;
    }

    public static void sendErrorEmail(String pAction, String pErrorMessage) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new List<String> {NOTIFICATION_EMAIL});
        email.setSubject('Quote Tweet Error: ' + Date.today());
        email.setPlainTextBody(pAction + ' failed with error: ' + pErrorMessage);
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage> {email});
    }
}