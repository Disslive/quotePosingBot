public without sharing class ImageGeneratorIntegration {
    private static final String IMAGE_GENERATOR_URL = 'callout:Cloudflare_API';
    private static final String PROMPT_FORMAT = 'Create an image inspired by the following quote: {0} The artwork should visually capture the meaning, mood, and emotion of the quote. Use appropriate colors, lighting, and composition to express its message in a thoughtful and creative way. The style can be realistic, artistic, or abstract — whichever best fits the feeling of the quote. DO NOT INCLUDE TEXT IN IMAGE';

    public static HttpResponse getImage(String pAuthor, String pQuote) {
        System.debug('ImageGeneratorIntegration.getImage...');

        Image_Generator_Keys__c imageGeneratorKeys = Image_Generator_Keys__c.getOrgDefaults();

        if (imageGeneratorKeys == null
                || String.isEmpty(pAuthor)
                || String.isEmpty(pQuote)) {
            return null;
        }

        ImageGeneratorDatamodel.ImageGeneratorRequest requestWrapper = new ImageGeneratorDatamodel.ImageGeneratorRequest(String.format(PROMPT_FORMAT, new List<String> {pQuote}));

        HttpRequest request = new HttpRequest();
        request.setEndpoint(IMAGE_GENERATOR_URL + '/client/v4/accounts/' + imageGeneratorKeys.Account_Id__c + '/ai/run/@cf/stabilityai/stable-diffusion-xl-base-1.0');
        request.setMethod('POST');
        request.setTimeout(60000);
        request.setHeader('Authorization', 'Bearer ' + imageGeneratorKeys.API_Key__c);
        request.setBody(JSON.serialize(requestWrapper));

        HttpResponse response = new Http().send(request);

        System.debug('response status code: ' + response.getStatusCode());
        System.debug('response body: ' + response.getBody());

        return response;
    }
}