public without sharing class ZenQuoteIntegration {
    private static final String QUOTE_API_URL = 'callout:Quotes_API' + '/api/today';

    public static HttpResponse getTodayQuote() {
        System.debug('ZenQuoteIntegration.getTodayQuote...');
        HttpRequest request = new HttpRequest();
        request.setEndpoint(QUOTE_API_URL);
        request.setMethod('GET');

        HttpResponse response = new Http().send(request);

        System.debug('response status code: ' + response.getStatusCode());
        System.debug('response body: ' + response.getBody());

        return response;
    }
}