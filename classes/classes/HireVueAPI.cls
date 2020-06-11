public class HireVueAPI {
    
	public class LoginResult {
        public Boolean isSuccess;
        public Map<String, String> mp_Credentials;
        public String errorCode;
        public String errorMessage;
    }
    
    public class SaveResult {
        public Boolean isSuccess;
        public String recordId;
        public Object data;
        public String errorCode;
        public String errorMessage;
    }
    
    public class QueryResult {
        public Boolean isSuccess;
        public Object data;
        public String errorCode;
        public String errorMessage; 
    }
}