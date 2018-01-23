public with sharing class Lightning_Auxiliary {
	public class PagedResult {
			// @AuraEnabled
			// public Integer pageSize { get; set; }
			//
			// @AuraEnabled
			// public Integer page { get; set; }

			@AuraEnabled
			public Integer recordCount { get; set; }

			@AuraEnabled
			public List<SObject> records { get; set; }

			@AuraEnabled
			public SObject firstValidMember { get; set; }
	}

	public class Config {
			@AuraEnabled
			public String nameSpacePrefix { get; set; }

			@AuraEnabled
			public String sObjectDescribesJson { get; set; }
	}

	public class Filter {
			@AuraEnabled
			public String searchKey { get; set; }

			@AuraEnabled
			public String relatedObject { get; set; }
	}

	public class Option implements Comparable {
		public Option(String label,String value) {
				this.label = label;
				this.value = value;
		}

			@AuraEnabled
			public String label { get; set; }

			@AuraEnabled
			public String value { get; set; }

			// Implement the compareTo() method
			public Integer compareTo(Object compareTo) {
					Option comp = (Option)compareTo;
					if (value < comp.value)
							return -1;
					if (value > comp.value)
							return 1;
					return 0;
			}
	}

	public class Criteria {
		public Decimal order;
	  public String objectName;
	  public String fieldName;
	  public String fieldDisplayName;
	  public String fieldType;
		public String operator;
	  public String fieldValue;
	  public String fieldValueType;
	  public String lastObjectName;
	  public String lastFieldName;
		public String referenceTo;
		public String lookupNameValue;
		// public Boolean toggle;
	}
}