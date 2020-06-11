@isTest
public class HireVueMultiRequestMock implements HttpCalloutMock {
	Map<String, HttpCalloutMock> requests;
 
    public HireVueMultiRequestMock(Map<String, HttpCalloutMock> requests) {
        this.requests = requests;
    }
 
    public HTTPResponse respond(HTTPRequest req) {
        System.debug('the end points = '+req.getEndpoint());
        HttpCalloutMock mock = requests.get(req.getEndpoint());
        if (mock != null) {
            return mock.respond(req);
        }
        return new HttpResponse();
    }
 
    public void addRequestMock(String url, HttpCalloutMock mock) {
        requests.put(url, mock);
    }
}