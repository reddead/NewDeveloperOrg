({
  nameSpacePrefix: '',
  spinner: null,

  doInit: function(component) {
    this.spinner = component.find('spinner');

    var action = component.get("c.getConfig");
    action.setStorable();
    action.setCallback(this, function(response) {
      var config = response.getReturnValue();
      component.set("v.config", config);
      this.nameSpacePrefix = component.get('v.config').nameSpacePrefix;

      var params = {};
      params.objectName = component.get('v.objectName');
      this.loadRecords(component, params);
    });
    $A.enqueueAction(action);
  },

  handleASGMT_HeaderEvt: function(component, event) {
    var self = this;
    var actionName = event.getParam('actionName');
    var parentRecord;
    var objectName = component.get('v.objectName');

    //new record
    if (actionName == 'new') {
      var title = '';

      if (objectName.indexOf('Assignment_Rule__c') != -1)
        title = 'Create Assignment Rule';
      else if (objectName.indexOf('Assignment_Rule_Entry__c') != -1) {
        title = 'Create Assignment Rule Entry';
        parentRecord = component.get('v.parentRecord');
      } else if (objectName.indexOf('Assignment_Queue__c') != -1)
        title = 'Create Assignment Queue';
      else if (objectName.indexOf('Assignment_Queue_Member__c') != -1) {
        title = 'Create Assignment Queue Member';
        parentRecord = component.get('v.parentRecord');
      }


      this.spinner.set('v.show', true);
      $A.createComponent(
        "c:ASGMT_ModalCustomForm", {
          "title": title,
          "config": component.get('v.config'),
          'type': 'CUSTOM_FORM',
          'objectName': objectName,
          "parentRecord": parentRecord
        },
        function(modalComponent, status, errorMessage) {
          if (status === "SUCCESS") {
            var targetCmp = component.find('ModalPlaceholder');
            var body = targetCmp.get("v.body");
            body.push(modalComponent);
            targetCmp.set("v.body", body);
            self.spinner.set('v.show', false);
          } else {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
              'title': 'Error: '+errorMessage,
              'message': ' ',
              'type': 'error'
            });
            toastEvent.fire();

            self.spinner.set('v.show', false);
          }
        }
      );
    } else if (actionName == 'back') {
      this.back(component);
    } else if (actionName == 'refresh') {
      var params = {};
      params.objectName = objectName;
      params.pageNumber = component.get('v.pageNumber');

      if (objectName.indexOf('Assignment_Rule_Entry__c') != -1)
        params.partialWhereClause = this.nameSpacePrefix + 'Assignment_Rule__c=\'' + component.get('v.parentRecordId') + '\' AND ';
      else if (objectName.indexOf('Assignment_Queue_Member__c') != -1)
        params.partialWhereClause = this.nameSpacePrefix + 'Assignment_Queue__c=\'' + component.get('v.parentRecordId') + '\' AND ';

      this.loadRecords(component, params);
    }
  },

  handlerASGMT_FilterEvt: function(component, event) {
    var objectName = event.getParam("objectName");
    if (objectName)
      component.set('v.objectName', objectName);

    var filter = component.get("v.filter");
    if (event.getParam("Name") !== undefined) {
      filter.Name = event.getParam("Name");
    }
    if (event.getParam("Related_Object__c") !== undefined) {
      filter.Related_Object__c = event.getParam("Related_Object__c");
    }
    component.set('v.filter', filter);

    var params = {};
    params.objectName = objectName;
    if (objectName === 'Assignment_Rule_Entry__c')
      params.partialWhereClause = this.nameSpacePrefix + 'Assignment_Rule__c=\'' + component.get('v.parentRecordId') + '\' AND ';
    else if (objectName === 'Assignment_Queue_Member__c')
      params.partialWhereClause = this.nameSpacePrefix + 'Assignment_Queue__c=\'' + component.get('v.parentRecordId') + '\' AND ';

    this.loadRecords(component, params);
  },

  handleASGMT_RecordTileEvt: function(component, event) {
    var self = this;
    var type = event.getParam('type');
    var record = event.getParam('record');
    var parentRecord;
    var objectName;
    var params;

    if (type == 'RECORD_EDIT') {
      this.spinner.set('v.show', true);
      $A.createComponent(
        "c:ASGMT_ModalCustomForm", {
          "title": 'Edit ' + record.Name,
          "config": component.get('v.config'),
          'objectName': component.get('v.objectName'),
          "record": record
        },
        function(modalComponent, status, errorMessage) {
          if (status === "SUCCESS") {
            var targetCmp = component.find('ModalPlaceholder');
            var body = targetCmp.get("v.body");
            body.push(modalComponent);
            targetCmp.set("v.body", body);
            self.spinner.set('v.show', false);
          } else {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
              'title': 'Error: '+errorMessage,
              'message': ' ',
              'type': 'error'
            });
            toastEvent.fire();

            self.spinner.set('v.show', false);
          }
        }
      );

    } else if (type == 'RECORD_DELETE') {
      objectName = component.get('v.objectName');

      var recordCount = component.get('v.recordCount');
      var pageNumber = component.get("v.pageNumber") || 1;
      var pageSize = component.get('v.pageSize');

      if (recordCount % pageSize == 1 && pageNumber > 1)
        pageNumber = pageNumber - 1;

      params = {};
      params.objectName = objectName;
      params.pageNumber = pageNumber;
      if (objectName === 'Assignment_Rule_Entry__c') {
        params.ruleEntryId = ''; //set empty for reOrderRuleEntry on delete event
        params.partialWhereClause = this.nameSpacePrefix + 'Assignment_Rule__c=\'' + component.get('v.parentRecordId') + '\' AND ';
      } else if (objectName === 'Assignment_Queue_Member__c')
        params.partialWhereClause = this.nameSpacePrefix + 'Assignment_Queue__c=\'' + component.get('v.parentRecordId') + '\' AND ';

      this.loadRecords(component, params);

    } else if (type == 'RELATED_LIST_GET') {


      component.set('v.recordCount', null);
      //set params for related list
      component.set("v.records", []); // re-init records
      var filter = {
        Name: ''
      };
      component.set('v.filter', filter);
      objectName = event.getParam("objectName");
      component.set("v.objectName", objectName);
      var parentObjectName = event.getParam("parentObjectName");
      component.set('v.parentObjectName', parentObjectName);
      parentRecord = event.getParam("parentRecord");
      component.set('v.parentRecord', parentRecord);
      // must set if(parentRecordId!=null) last for parent record to init rendering
      var parentRecordId = event.getParam("parentRecordId");
      component.set('v.parentRecordId', parentRecordId);

      params = {};
      params.objectName = objectName;
      if (objectName.indexOf('Assignment_Rule_Entry__c') != -1)
        params.partialWhereClause = this.nameSpacePrefix + 'Assignment_Rule__c=\'' + component.get('v.parentRecordId') + '\' AND ';
      else if (objectName.indexOf('Assignment_Queue_Member__c') != -1) {
        params.partialWhereClause = this.nameSpacePrefix + 'Assignment_Queue__c=\'' + component.get('v.parentRecordId') + '\' AND ';

        component.set('v.pageSize', 15);
      }

      this.loadRecords(component, params);
    } else if (type == 'CRITERIA_SET_EDIT') {
      objectName = event.getParam('objectName'); //Assignment_Rule_Entry__c

      parentRecord = component.get('v.parentRecord');
      var relatedObject = parentRecord[this.nameSpacePrefix + 'Related_Object__c'];

      this.spinner.set('v.show', true);
      $A.createComponent(
        "c:ASGMT_ModalCriteriaSet", {
          'type': 'CRITERIA_SET',
          'title': record.Name + ' - Criteria Set',
          "config": component.get("v.config"),
          "objectName": objectName, //Assignment_Rule_Entry__c
          "record": record, //Assignment_Rule_Entry__c record
          "relatedObject": relatedObject, //Assignment_Rule__c.Related_Object__c
        },
        function(modalComponent, status, errorMessage) {
          if (status === "SUCCESS") {
            var targetCmp = component.find('ModalPlaceholder');
            var body = targetCmp.get("v.body");
            body.push(modalComponent);
            targetCmp.set("v.body", body);
            self.spinner.set('v.show', false);
          } else {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
              'title': 'Error: '+errorMessage,
              'message': ' ',
              'type': 'error'
            });
            toastEvent.fire();

            self.spinner.set('v.show', false);
          }
        }
      );
    }
  },

  handleASGMT_ModalEvt: function(component, event) {
    var type = event.getParam('type');
    var record = event.getParam('record');
    var objectName = component.get('v.objectName');
    var pageNumber = component.get('v.pageNumber');

    var params = {};
    params.objectName = objectName;
    params.pageNumber = pageNumber;

    if (type == 'RECORD_CHANGE') {
      if (objectName.indexOf('Assignment_Rule__c') != -1 && record) {
        params.ruleId = record.Id;
        params.isRuleActive = record[this.nameSpacePrefix + 'Active__c'];
        params.ruleRelatedObject = record[this.nameSpacePrefix + 'Related_Object__c'];

        this.loadRecords(component, params);
      } else if (objectName.indexOf('Assignment_Rule_Entry__c') != -1 && record) {
        var oldOrder = event.getParam('oldOrder');
        oldOrder = oldOrder ? oldOrder : record[this.nameSpacePrefix + 'Order__c'];
        params.ruleEntryId = record.Id;
        params.ruleEntryOldOrder = oldOrder.toString();
        params.partialWhereClause = this.nameSpacePrefix + 'Assignment_Rule__c=\'' + component.get('v.parentRecordId') + '\' AND ';
      } else if (objectName.indexOf('Assignment_Queue_Member__c') != -1)
        params.partialWhereClause = this.nameSpacePrefix + 'Assignment_Queue__c=\'' + component.get('v.parentRecordId') + '\' AND ';

      this.loadRecords(component, params);
    } else if (type == 'CRITERIA_SET_CHANGE') {
      params.partialWhereClause = this.nameSpacePrefix + 'Assignment_Rule__c=\'' + component.get('v.parentRecordId') + '\' AND ';
      this.loadRecords(component, params);
    }
  },

  back: function(component) {
    var objectName = component.get('v.objectName');
    if (objectName.indexOf('Assignment_Rule_Entry__c') != -1) {
      var drake = component.get('v.drake');
      drake.destroy();
    }

    var parentObjectName = component.get('v.parentObjectName');
    var filter;
    if (parentObjectName.indexOf('Assignment_Rule__c') != -1)
      filter = {
        Name: '',
        Related_Object__c: ''
      };
    else
      filter = {
        Name: ''
      };
    component.set('v.filter', filter);

    component.set("v.records", []); // re-init records
    component.set('v.objectName', parentObjectName);
    component.set('v.parentObjectName', null);
    component.set('v.parentRecordId', null);
    component.set('v.parentRecord', null);
    component.set('v.recordCount', null);


    var params = {};
    params.objectName = parentObjectName;
    component.set('v.pageSize', 12);
    this.loadRecords(component, params);

    var ASGMT_TabEvt = $A.get("e.c:ASGMT_TabEvt");
    ASGMT_TabEvt.setParams({
      "tabId": parentObjectName
    });
    ASGMT_TabEvt.fire();
  },

  onPreviousPage: function(component) {
    var pageNumber = component.get("v.pageNumber") || 1;
    //var direction = event.getParam("direction");
    pageNumber = pageNumber - 1;
    component.set("v.pageNumber", pageNumber);

    var objectName = component.get("v.objectName");

    var params = {};
    params.objectName = objectName;
    params.pageNumber = pageNumber;

    if (objectName === 'Assignment_Rule_Entry__c')
      params.partialWhereClause = this.nameSpacePrefix + 'Assignment_Rule__c=\'' + component.get('v.parentRecordId') + '\' AND ';
    else if (objectName === 'Assignment_Queue_Member__c')
      params.partialWhereClause = this.nameSpacePrefix + 'Assignment_Queue__c=\'' + component.get('v.parentRecordId') + '\' AND ';

    this.loadRecords(component, params);
  },

  onNextPage: function(component) {
    var pageNumber = component.get("v.pageNumber") || 1;
    //var direction = event.getParam("direction");
    pageNumber = pageNumber + 1;
    component.set("v.pageNumber", pageNumber);

    var objectName = component.get("v.objectName");

    var params = {};
    params.objectName = objectName;
    params.pageNumber = pageNumber;

    if (objectName === 'Assignment_Rule_Entry__c')
      params.partialWhereClause = this.nameSpacePrefix + 'Assignment_Rule__c=\'' + component.get('v.parentRecordId') + '\' AND ';
    else if (objectName === 'Assignment_Queue_Member__c')
      params.partialWhereClause = this.nameSpacePrefix + 'Assignment_Queue__c=\'' + component.get('v.parentRecordId') + '\' AND ';

    this.loadRecords(component, params);
  },

  initDragula: function(component, callBackTime) {
    var objectName = component.get('v.objectName');
    if (objectName.indexOf('Assignment_Rule_Entry__c') != -1) {
      var list = component.find('list').getElement();
      var drake = dragula([list]);
      var self = this;
      drake.on('drop', $A.getCallback(function(el, target, source, sibling) {
        var tileList = $('#tile-list li');
        var recordId = el.getAttribute('data-id');
        var oldOrder = el.getAttribute('data-order');
        var newOrder;

        for (var i = 0; i < tileList.length; i++) {
          if (tileList[i].getAttribute('data-id') == recordId) {
            newOrder = i + 1;
            break;
          }
        }
        self.updateRuleEntryOrder(component, recordId, newOrder, oldOrder);
      }));
      component.set('v.drake', drake);

      window.setTimeout(
        $A.getCallback(function() {
          var spinner = component.find('spinner');
          if (spinner)
            spinner.set('v.show', false);
        }), callBackTime + 200
      );
    }
  },

  updateRuleEntryOrder: function(component, recordId, newOrder, oldOrder) {
    var action = component.get("c.updateRuleEntryOrder");
    //action.setStorable();

    action.setParams({
      "recordId": recordId,
      "newOrder": newOrder.toString()
    });

    action.setCallback(this, function(response) {
      console.log('# updateRuleEntryOrder callback %fms', (performance.now() - startTime));
      var state = response.getState();
      if (state === "SUCCESS") {
        var params = {};
        params.objectName = component.get('v.objectName');
        params.pageNumber = component.get('v.pageNumber');
        params.ruleEntryId = recordId;
        params.ruleEntryOldOrder = oldOrder.toString();
        params.partialWhereClause = this.nameSpacePrefix + 'Assignment_Rule__c=\'' + component.get('v.parentRecordId') + '\' AND ';

        this.loadRecords(component, params);
      }
    });
    var startTime = performance.now();
    $A.enqueueAction(action);
  },

  loadRecords: function(component, params) {

    var action = component.get("c.getPagedResult");
    //action.setStorable();

    var objectName = params.objectName;
    var filter = component.get("v.filter");

    var pageSize = component.get("v.pageSize");
    var pageNumber = params.pageNumber;
    pageNumber = pageNumber || 1;
    var offset = (pageNumber - 1) * pageSize;

    var customFields = '';
    var whereClause = '';
    if (objectName.indexOf('Assignment_Queue_Member__c') != -1) {
      customFields = this.nameSpacePrefix + 'User__r.Name';
      whereClause += this.nameSpacePrefix + 'User__r.Name LIKE \'%' + filter.Name + '%\' AND ';
    } else {
      if (objectName.indexOf('Assignment_Rule_Entry__c') != -1)
        customFields = this.nameSpacePrefix + 'Assign_To_User__r.Name,' + this.nameSpacePrefix + 'Assign_To_Queue__r.Name';
      else if (objectName.indexOf('Assignment_Queue__c') != -1) {
        customFields+='(select Id from ' + this.nameSpacePrefix + 'Assignment_Queue_Members__r where ' + this.nameSpacePrefix + 'Member_Status__c=\'Valid\')';
      }

      for (var property in filter) {
        if (filter.hasOwnProperty(property)) {
          var filterName;
          if (property.indexOf('__c') != -1) {
            filterName = this.nameSpacePrefix + property;
          } else
            filterName = property;

          whereClause += filterName + ' LIKE \'%' + filter[property] + '%\' AND ';
        }
      }
    }
    if (params.partialWhereClause)
      whereClause += params.partialWhereClause;
    whereClause = whereClause.substring(0, whereClause.length - 5);

    var otherClause;
    if (objectName.indexOf('Assignment_Rule__c') != -1)
      otherClause = 'Order By ' + this.nameSpacePrefix + 'Related_Object__c,Name LIMIT ' + pageSize + ' OFFSET ' + offset;
    else if (objectName.indexOf('Assignment_Rule_Entry__c') != -1) {
      otherClause = 'Order By ' + this.nameSpacePrefix + 'Order__c,LastModifiedDate DESC';
    } else if (objectName.indexOf('Assignment_Queue_Member__c') != -1)
      otherClause = 'Order By ' + this.nameSpacePrefix + 'Last_Assignment__c,' + this.nameSpacePrefix + 'Millisecond__c,' + this.nameSpacePrefix + 'User__r.Name LIMIT ' + pageSize + ' OFFSET ' + offset;
    else
      otherClause = 'Order By Name LIMIT ' + pageSize + ' OFFSET ' + offset;

    if (objectName.indexOf('__c') != -1)
      objectName = this.nameSpacePrefix + objectName;
    action.setParams({
      "objectName": objectName,
      "customFields": customFields,
      "whereClause": whereClause,
      "otherClause": otherClause,
      "paramsJson": JSON.stringify(params)
    });

    var spinner = component.find('spinner');
    spinner.set('v.show', true);

    var self = this;
    action.setAbortable();
    action.setCallback(this, function(response) {
      var callBackTime = performance.now() - startTime;
      console.log('# getSObjectRecords callback %fms', (performance.now() - startTime));
      var result = response.getReturnValue();

      if (result.records.length == 0)
        component.set("v.pageNumber", 0);
      else
        component.set("v.pageNumber", pageNumber);
      component.set("v.recordCount", result.recordCount);
      component.set("v.pageCount", Math.ceil(result.recordCount / pageSize));

      //init dragula after Assignment_Rule_Entry__c records loaded
      if (objectName.indexOf('Assignment_Rule_Entry__c') != -1) {
        if (result.records.length == 0)
          component.set("v.pageCount", 0);
        else
          component.set("v.pageCount", 1);

        spinner.set('v.show', true);
        window.setTimeout(
          $A.getCallback(function() {
            var drake = component.get('v.drake');
            if (drake) {
              drake.destroy();
              component.set('v.drake', drake);
              self.initDragula(component, callBackTime);
            } else
              self.initDragula(component, callBackTime);
          }), 0);
      } else if (objectName.indexOf('Assignment_Queue_Member__c') != -1) {
        var parentRecord=component.get('v.parentRecord');
        if(parentRecord[this.nameSpacePrefix + 'Assignment_Queue_Members__r']){
          parentRecord[this.nameSpacePrefix + 'Assignment_Queue_Members__r'].length=0;
          for(var i=0;i<result.records.length;i++){
            if(result.records[i][this.nameSpacePrefix+'Member_Active__c']&&result.records[i][this.nameSpacePrefix+'User_Active__c'])
              parentRecord[this.nameSpacePrefix + 'Assignment_Queue_Members__r'].length++;
          }
        }
        else{
          parentRecord[this.nameSpacePrefix + 'Assignment_Queue_Members__r']={};
          parentRecord[this.nameSpacePrefix + 'Assignment_Queue_Members__r'].length=0;
        }
        component.set('v.parentRecord',parentRecord);

        if (result.firstValidMember)
          component.set("v.firstValidMember", result.firstValidMember);
      }

      component.set("v.records", result.records);
      spinner.set('v.show', false);
    });
    var startTime = performance.now();
    $A.enqueueAction(action);
  },
})
