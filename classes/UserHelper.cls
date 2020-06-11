public class UserHelper {
    public static Boolean isTriggerRun = false;
    public static void afterInsert(Map<Id, User> newUserMap, Map<Id, User> oldUserMap) {
       processRecordsForHireVue(newUserMap, oldUserMap);
    }
    public static void afterUpdate(Map<Id, User> newUserMap, Map<Id, User> oldUserMap) {
        processRecordsForHireVue(newUserMap, oldUserMap);
    }
    
    public static void processRecordsForHireVue(Map<Id, User> newUserMap, Map<Id, User> oldUserMap) {
        for (User usr : [SELECT isActive, Hirevue_Position_Id__c, UserRole.Name FROM User WHERE Id IN :newUserMap.keySet() AND UserRole.Name =: HireVueConstants.USR_ROLE_SCREENER]) {
            if (String.isBlank(usr.Hirevue_Position_Id__c) && usr.isActive) {
                createUserAlongWithPositionInHireVue(usr.Id);
            } else if (!String.isBlank(usr.Hirevue_Position_Id__c) && (oldUserMap != null && usr.isActive != oldUserMap.get(usr.Id).isActive)) {
                updateHireVueUser(usr.Id);
            }
        }
    }
    
    @future(callout=true)
    public static void createUserAlongWithPositionInHireVue(Id userId) {
        String hireVueUserEmail;
        String hireVuePositionId;
        String message;
        User sfUser;
        HireVueconnector connector = new HireVueconnector();
        try {
        	sfUser = [SELECT Id, Name, FirstName, LastName, Email, MobilePhone, LanguageLocaleKey, Phone FROM User WHERE Id = :userId];
            HireVueAPI.LoginResult loginRslt;
            if (connector.mp_Credentials.isEmpty()) {
                loginRslt = connector.getLoginCrendentials(null);
                connector.mp_Credentials = loginRslt.mp_Credentials;
                if(!loginRslt.isSuccess) {
                    message = 'Login Failed : error-code : '+loginRslt.errorCode+', error-message : '+loginRslt.errorMessage;
                    connector.createErrorLog('HireVue User Creation with username('+sfUser.Email+')', null, message, message, 'UserHelper.cls', 'createUserAlongWithPositionInHireVue');
                    return;
                }
            }
            hireVueUserEmail = sfUser.Email;
            HireVueApi.QueryResult usrQryRslt = connector.getUser(hireVueUserEmail);
            Boolean isUserAlreadyExist = true;
            if (!usrQryRslt.isSuccess && usrQryRslt.errorCode == HireVueConstants.ERROR_USER_NOT_FOUND) {
                isUserAlreadyExist = false;
                HireVueObjects.User usr = new HireVueObjects.User();
                usr.accountId = Long.valueOf(connector.mp_HireVueConfigs.get(HireVueConstants.HIREVUE_CONFIG_KEY_ACCOUNT_ID));
                usr.firstName = sfUser.FirstName;
                usr.lastName = sfUser.LastName;
                usr.email = sfUser.Email;
                usr.language = 'en';
                usr.teams = new List<HireVueObjects.Team>();
                HireVueObjects.Team team = new HireVueObjects.Team();
                team.id = Long.valueOf(connector.mp_HireVueConfigs.get(HireVueConstants.HIREVUE_CONFIG_KEY_POSITION_TEAM_ID));
                team.role = 'member';
                usr.teams.add(team);
                HireVueApi.SaveResult usrRslt = connector.createUser(usr);
                if(!usrRslt.isSuccess) {
                    message = 'User Creation Failed : error-code : '+usrRslt.errorCode+', error-message : '+usrRslt.errorMessage;
                    connector.createErrorLog('HireVue User Creation with username('+sfUser.Email+')', null, message, message, 'UserHelper.cls', 'createUserAlongWithPositionInHireVue');
                    return;
                }    
            }
            loginRslt = connector.getLoginCrendentials(hireVueUserEmail);
            connector.mp_Credentials = loginRslt.mp_Credentials;
            if(!loginRslt.isSuccess) {
                message = 'User login Failed for username('+hireVueUserEmail+') : error-code : '+loginRslt.errorCode+', error-message : '+loginRslt.errorMessage;
                connector.createErrorLog('HireVue User Creation with username('+sfUser.Email+')', null, message, message, 'UserHelper.cls', 'createUserAlongWithPositionInHireVue');
                return;
            }
            if (isUserAlreadyExist) {
                HireVueAPI.QueryResult qryRslt = connector.getPositionsAvailableForUser(hireVueUserEmail);
                if (qryRslt.isSuccess && qryRslt.data != null) {
                   List<HireVueObjects.Position> lst_HireVuePostions = (List<HireVueObjects.Position>)qryRslt.data;
                    if (!lst_HireVuePostions.isEmpty()) {
                        for (HireVueObjects.Position pos : lst_HireVuePostions) {
                            if (pos.interviewType == HireVueConstants.INTERVIEW_TYPE_LIVE_RECORDED) {
                                hireVuePositionId = String.valueOf(pos.id);
                                break;
                            }
                        }  
                    }
                }    
            }
            if (String.isBlank(hireVuePositionId)) {
                HireVueAPI.SaveResult posRst = connector.createPosition(hireVueUserEmail);
                if(!posRst.isSuccess) {
                    message = 'Position creation failed : error-code : '+posRst.errorCode+', error-message : '+posRst.errorMessage;
                    connector.createErrorLog('HireVue User Creation with username('+sfUser.Email+')', null, message, message, 'UserHelper.cls', 'createUserAlongWithPositionInHireVue');
                    return;
                }
                hireVuePositionId = posRst.recordId;
                HireVueAPI.SaveResult hireVueRslt = connector.getAndUpdateSessionOnPostion(hireVuePositionId, hireVueUserEmail);
                if(!hireVueRslt.isSuccess) {
                    message = 'Session Fetch Failed : error-code : '+hireVueRslt.errorCode+', error-message : '+hireVueRslt.errorMessage;
                    connector.createErrorLog('HireVue User Creation with username('+sfUser.Email+')', null, message, message, 'UserHelper.cls', 'createUserAlongWithPositionInHireVue');
                    return;
                }
                HireVueObjects.Position position = new HireVueObjects.Position();
                position.isDraft = false;
                hireVueRslt = connector.updatePosition(hireVuePositionId, position);
                if(!hireVueRslt.isSuccess) {
                    message = 'Position Update Failed : error-code : '+hireVueRslt.errorCode+', error-message : '+hireVueRslt.errorMessage;
                    connector.createErrorLog('HireVue User Creation with username('+sfUser.Email+')', null, message, message, 'UserHelper.cls', 'createUserAlongWithPositionInHireVue');
                    return;
                }
            }   
            update new User(Id = userId,Hirevue_Position_Id__c = hireVuePositionId);    
        } catch(Exception ex) {
            connector.createErrorLog('HireVue User Creation with username('+sfUser.Email+')', ex.getLineNumber(), ex.getMessage(), ex.getStackTraceString(), 'UserHelper.cls', 'createUserAlongWithPositionInHireVue');
        }
    }
    @future(callout=true)
    public static void updateHireVueUser(Id userId) {
        String message;
        User sfUser;
        HireVueConnector con = new HireVueConnector();
        try {
            sfUser = [SELECT Id, isActive, Email FROM User WHERE Id = :userId];
            HireVueObjects.User usr = new HireVueObjects.User();
            usr.enabled = sfUser.isActive;
            HireVueAPI.SaveResult updateRst = con.updateUser(usr, sfUser.Email);
			if(!updateRst.isSuccess) {
                message = 'User Activation/Deactivation Failed : error-code : '+updateRst.errorCode+', error-message : '+updateRst.errorMessage;
                con.createErrorLog('HireVue User Activation/Deactivation for username('+sfUser.Email+')', null, message, message, 'UserHelper.cls', 'updateHireVueUser');
                return;
            }            
        } catch(Exception ex) {
            con.createErrorLog('HireVue User Activation/Deactivation for username('+sfUser.Email+')', ex.getLineNumber(), ex.getMessage(), ex.getStackTraceString(), 'UserHelper.cls', 'updateHireVueUser');
        } 
    }
}