public without sharing class TwitterDatamodel {
    public class TweetRequest {
        public String text;
        public Media media;

        public TweetRequest(String pText, List<String> pMediaIdList) {
            this.text = pText;
            this.media = new Media();

            for (String mediaId_i : pMediaIdList) {
                this.media.addId(mediaId_i);
            }
        }
    }

    public class Media {
        List<String> media_ids;

        public Media() {
            this.media_ids = new List<String>();
        }

        public void addId(String pMediaId) {
            this.media_ids.add(pMediaId);
        }
    }

    public class MediaUploadRequest {
        public Blob media;
        public String media_category;
        public String media_type;
        public MediaUploadRequest(Blob pFile) {
            this.media = pFile;
            this.media_category = 'tweet_image';
            this.media_type = String.valueOf(pFile).containsIgnoreCase('PNG')
                ? 'image/png'
                : 'image/jpeg';
        }
    }

    public class MediaUploadResponse {
        public MediaUploadData data;
    }

    public class MediaUploadData {
        public String id;
    }

    public class Token {
        public String access_token;
        public String refresh_token;
    }
}