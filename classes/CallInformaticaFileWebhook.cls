public class CallInformaticaFileWebhook implements Queueable, Database.AllowsCallouts {
    String sourceType;
    String fileName;

    public CallInformaticaFileWebhook(String sourceType, String fileName) {
        this.sourceType = sourceType;
        this.fileName = fileName;
    }

    public void execute(QueueableContext context) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://your-informatica-endpoint.com/webhook');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');

        Map<String, Object> payload = new Map<String, Object>{
                'sourceType' => sourceType,
                'fileName'   => fileName
        };

        req.setBody(JSON.serialize(payload));

        Http http = new Http();
        try {
            HttpResponse res = http.send(req);
            System.debug('Informatica callout status: ' + res.getStatus());
        } catch (Exception e) {
            System.debug('Failed to trigger Informatica workflow: ' + e.getMessage());
        }
    }
}
