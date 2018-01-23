public with sharing class Lightning_Constant {
	public static final String CONTACT = 'Contact';
    public static final String ASSIGNMENT_RULE = Lightning_Utility.getSObjectName(Assignment_Rule__c.sObjectType);
    public static final String ASSIGNMENT_QUEUE = Lightning_Utility.getSObjectName(Assignment_Queue__c.sObjectType);

    public enum RequiredFieldTypes {
      ALL_FIELDS,
      ALL_FIELDS_WITH_CUSTOM_FIELDS,
      ONLY_FIELDSET_FIELDS,
      ONLY_CUSTOM_FIELDS,
      FIELDSET_FIELDS_CUSTOM_FIELDS
    }

    public static String SELECT_CLAUSE = 'SELECT ';
    public static String WHERE_CLAUSE = ' WHERE ';
    public static String FROM_CLAUSE = ' FROM ';

	public static final String EQUALS = 'equals';
    /****
    * @description operator used for rendered condition
    */
    public static final String DOSE_NOT_EQUAL = 'does not equal';
    /****
    * @description operator used for rendered condition
    */
    public static final String CONTAINS = 'contains';
    /****
    * @description operator used for rendered condition
    */
    public static final String DOES_NOT_CONTAIN = 'does not contain';
    /****
    * @description operator used for rendered condition
    */
    public static final String STARTS_WITH = 'starts with';
    /****
    * @description operator used for rendered condition
    */
    public static final String ENDS_WITH = 'ends with';
    /****
    * @description operator used for rendered condition
    */
    public static final String INCLUDES = 'includes';
    /****
    * @description operator used for rendered condition
    */
    public static final String EXCLUDES = 'excludes';
    /****
    * @description operator used for rendered condition
    */
    public static final String LESS_THAN = 'less than';
    /****
    * @description operator used for rendered condition
    */
    public static final String GREATER_THAN = 'greater than';
    /****
    * @description operator used for rendered condition
    */
    public static final String LESS_OR_EQUAL = 'less or equal';
    /****
    * @description operator used for rendered condition
    */
    public static final String GREATER_OR_EQUAL = 'greater or equal';
    /****
    * @description operator used for rendered condition
    */
    public static final String WITHIN = 'within';
}