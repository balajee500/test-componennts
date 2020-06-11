/*********************************************************************************************************************************************
 *  Class       :   HireVueObjects
 *  Author      :   Tekclan Software Solutions PVT. LTD.
 *  Created By  :   Balaji Jayaraman
 *  Purpose     :   This is a model class used during creating and parsing JSON data
 *
 ********************************************************************************************************************************************/
public class HireVueObjects {
    
	public class Position {
        public Long id;
        public String pocName;
        public String visibility;
        public String pocPhone;
        public String ratingMode;
        public String pocEmail;
        public String interviewType;
        public String pocUrl;
        public Boolean isOpenvue;
        public String dataStorageRuleset;
        public String publicTitle;
        public Boolean disablePoc;
        public String title;
        public Integer introVideoId;
        public Long teamId;
        public Integer closingVideoId;
        public Boolean isDraft;
        public User creator;
    }
    
    public class Session {
        public list<Location> locations;
        public list<Long> durations;
        public list<Participant> participants;
        public list<String> sessionOrders;
        public list<Question> questions;
        public String notes;
        public String name;
        public Long id;
    }
    
    public class Section {
        public String image;
        public String instructions;
        public Boolean restrictNavigation;
        public Integer maxDuration;
        public Boolean forceQuestionResponse;
        public list<Form> forms;
        public String name;
        public Long id;
    }
    
    public class Candidate {
        public String liveType;
        public String lastName;
        public String fullName;
        public Integer id;
        public String archived;
        public String phone;
        public String postalCode;
        public String firstName;
        public HireVueVideo video;
        public EvaluationSummary summary;
        public list<String> documents;
        public list<InterViewer> participants;
        public EvaluationDetail myEvaluation;
        public List<Evaluation> evaluations;
        public String country;
        public String email;
        public String resumeId;
        public String takenDate;
        public Boolean liveInterviewUsedWhiteboard;
        public String candidateInstructions;
        public String language;
        public String website;
        public String city;
        public String lastStatusChangeDate;
        public String candidateExitUrl;
        public String createDate;
        public String status;
        public String audioMode;
        public Boolean isArchived;
        public Boolean liveInterviewChatRecorded;
        public String interviewAddress;
        public String stateOrProvince;
        public Integer durationMinutes;
        public Boolean isOpenvue;
        public String startTime;
        public String timezone;
        public String code;
    }
    
    public class QuestionTemplate {
        public String name;
        public list<Question> questions;
        public Long id;
    }
    
    public class Form {
        public String name;
        public list<Question> questions;
        public Long id;
    }
    
    public class User {
        public String lastName;
        public String fullName;
        public String firstName;
        public String username;
        public String email;
        public String phone;
        public String accountRole;
        public String language;
        public Boolean isActive;
        public Boolean enabled;
        public List<Team> teams;
        public Long accountId;
    }
    
    public class Team {
        public Long id;
        public String role;
    }
    
    public class Room {
        public String email;
        public String name;
    }
    
    public class Question {
        public Integer maxDuration;
        public String type;
        public String text;
        public Integer prepTimeSeconds;
        public Integer maxCharacters;
        public String defaultText;
        public Boolean isRatable;
        public String insightsModelQuestionId;
    }
    
    public class Participant {
        public Integer count;
        public list<User> users;
    }
    
    public class Location {
        public Integer count;
        public list<Room> rooms;
    }
    
    public class InterViewer{
		public String username;
		public String fullName;
		public String firstName;
		public String lastName;
        public Boolean isAutoAssign;
        public Boolean isRemoved;
        public Boolean isInactive;
	}
    
    public class Event {
        public String eventType;
		public EventDetail details;
    }
    
    public class EventDetail {
        public String author;
		public String decision;
		public Integer interview_id;
		public String code;
        public Integer rating;
    }
    
    public class EvaluationDetail {
        public Boolean isComplete;
        public String decision;
        public Boolean isParticipant;
        public String participantCode;
        public Boolean isAssigned;
    }
    
    public class Notification {
        public String url;
    }
    public class HireVueVideo {
        public Boolean isTranscoded;
        public String thumbnailUrl;
        public DownloadUrl downloadUrls;
        public Integer id;
        public String name;
        public String type;
    }
    public class DownloadUrl {
        public String mp4;
    }
    public class EvaluationSummary {
        public String averageCodevueScore;
		public String insightsStatus;
		public Decimal averageRating;
		public String insightsRankingScaled;
		public Integer assignedEvaluationCount;
		public Integer completedEvaluationCount;
		public Integer commentCount;
		public Integer questionCount;
		public Integer decisionCount;
		public Integer answerCount;
    }
    
    public class Assignment {
        public Boolean isAutoAssign;
        public List<AssignmentDetail> assignments;
    }
    
    public class AssignmentDetail {
       public Boolean isAssigned;
       public Long interviewId; 
    }
    
    public class Comment {
        public String text;
        public String category;
        public Long id;
        public String createDate;
        public String modifyDate;
        public String offsetMillis;
        public InterViewer author;
    }
    
    public class Evaluation {
        public Decimal averageRating;
        public String decision;
        public InterViewer evaluator;
    }
}