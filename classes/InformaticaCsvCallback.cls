@RestResource(urlMapping='/informatica/filecallback')
global with sharing class InformaticaCsvCallback {

    @HttpPost
    global static String handleCsvUpload() {
        try {
            RestRequest req = RestContext.request;

            // Optional: get filename from header or query param
            String fileName = req.headers.get('X-Filename');
            if (String.isBlank(fileName)) {
                fileName = 'wire_import_' + DateTime.now().getTime() + '.csv';
            }

            Blob fileBlob = Blob.valueOf(req.requestBody.toString());

            ContentVersion cv = new ContentVersion(
                    Title = fileName,
                    PathOnClient = '/' + fileName,
                    VersionData = fileBlob,
                    IsMajorVersion = true
            );
            insert cv;

            // Launch batch job if needed
            cv = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
            Database.executeBatch(new BatchProcessAccountsFromCsv(cv.ContentDocumentId), 1);

            return 'CSV file received and batch job started for ' + fileName;
        } catch (Exception e) {
            RestContext.response.statusCode = 400;
            return 'Error: ' + e.getMessage();
        }
    }
}