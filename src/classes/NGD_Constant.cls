public with sharing class NGD_Constant {
	public static final String CONTACT = 'Contact';
	public static final String APPLICATION = 'Application__c';
	public static final String HOMEPAGE_LAYOUT = 'Homepage_Widget_Layout__c';
	public static final String HOMEPAGE_TEMPLATE = 'Homepage_Template__c';
	public static final String HOMEPAGE_WIDGET = 'Homepage_Widget__c';

    public enum RequiredFieldTypes {
      ALL_FIELDS,
      ALL_FIELDS_WITH_CUSTOM_FIELDS,
      ONLY_FIELDSET_FIELDS,
      ONLY_CUSTOM_FIELDS,
      FIELDSET_FIELDS_CUSTOM_FIELDS
    }

	public static final String EQUALS = 'Equals';
    /****
    * @description operator used for rendered condition
    */
    public static final String DOSE_NOT_EQUAL = 'Does not equal';
    /****
    * @description operator used for rendered condition
    */
    public static final String CONTAINS = 'Contains';
    /****
    * @description operator used for rendered condition
    */
    public static final String DOES_NOT_CONTAIN = 'Does not contain';
    /****
    * @description operator used for rendered condition
    */
    public static final String STARTS_WITH = 'Starts with';
    /****
    * @description operator used for rendered condition
    */
    public static final String ENDS_WITH = 'Ends with';
    /****
    * @description operator used for rendered condition
    */
    public static final String INCLUDES = 'Includes';
    /****
    * @description operator used for rendered condition
    */
    public static final String EXCLUDES = 'Excludes';
    /****
    * @description operator used for rendered condition
    */
    public static final String LESS_THAN = 'Less than';
    /****
    * @description operator used for rendered condition
    */
    public static final String GREATER_THAN = 'Greater than';
    /****
    * @description operator used for rendered condition
    */
    public static final String LESS_THAN_EQUALS = 'Less or equal';
    /****
    * @description operator used for rendered condition
    */
    public static final String GREATER_THAN_EQUALS = 'Greater or equal';
}