"use strict";

var QB = QB || {};

QB.AppTables = function( appDbId, tableData, pageToken ) {
  this.appDbId = appDbId;
  QB.AppTables.addRelationshipsFromGlobals( tableData );
  setupResizeTrigger();
  this.addTableMenu = function( tab ) { 
    var dbid = tab.get( "tableDbId" );
    $( "#moreTablesButton" ).before( ich.newTableMenu( { id:dbid, name:tab.get( "label" ) }, true ) );
    $( "#tablesMenuBar" ).append( ich.customizeMenu( { id:tab.get( "tableDbId" ) }, true ) );
    $( "#tblMenuItems_" + dbid ).qbMenu( { trigger:{ selector:"#tblMenuTrigger_" + dbid, highlight:"Open" } } ) 
  };
  var AppTablesModel = Backbone.Model.extend( { 
    serverFieldNameMap:{}, 
    defaults:{}, 
    initialize:function() { 
      this.bind( "error", 
                  function( model, error) { 
                    if( console !== undefined ) { 
                      console.log( error ) 
                    }
                  } 
               )
    }, 
    validate:function( attrs ) { 
      if( attrs.hasOwnProperty( "id" ) && attrs.id===undefined ){ 
        return "id is undefined" 
      }
    }
  } );
  
var self=this;

var AppTablesToolbar = QB.BaseToolbarView.extend( {
  initialize:function() {
    QB.BaseToolbarView.prototype.initialize.call( this, this.options );
    this.parent = this.options.el;
    _.bindAll( this )
  },
  newTable:function( e ) {
    var defaultName = self.collection.getNextTableName();
    var toolbar = this;
    AskNewTable( defaultName, function( result ) { 
      if( $( result ).find( "errcode" ).text() != "0" ) {
        QBDialog.alert( $( result ).find( "errdetail" ).text(), {}, "Error" );
        return false
      }
      var dbid = $( result ).find( "newdbid" ).text();
      toolbar.displayNewTable( dbid )
    }
  ) },
  displayNewTable:function( dbid ) { 
    self.collection.each( function ( model ) { model.set( { isNew:false } ) } );
    var data = { tableDBID:dbid, PageToken:self.collection.pageToken };
    $.post( 
      self.collection.getTableInfoAction, 
      data, 
      function( data, textStatus, resp ) { var xmlResponse = $( getXMLresp( resp.responseText ) );
        if( xmlResponse.find( "errcode" ).text() == "0" ) {
          var newTable=new AppTablesModel( { 
            label:xmlResponse.find( "tablename" ).text(),
            tableDbId:xmlResponse.find( "tableDBID" ).text(),
            description:xmlResponse.find( "tableDescription" ).text(),
            numForms:parseInt( xmlResponse.find( "numforms" ).text() ),
            numFields:parseInt( xmlResponse.find( "numfields" ).text() ),
            numRels:parseInt( xmlResponse.find( "numrels" ).text() ),
            numReports:parseInt( xmlResponse.find( "numreports" ).text() ),
            numEmails:parseInt( xmlResponse.find( "numemails" ).text() ),
            hideFromMenuBar:xmlResponse.find( "hideFromMenuBar" ).text() == "true",
            tableLocked:xmlResponse.find( "tableLock" ).text() == "true",
            relNames:"",
            isNew:true,
            id:self.collection.length,
            order:self.collection.length
          } );
          self.collection.add( newTable );
          self.addTableMenu( newTable ) 
        } else { 
          self.collection.trigger( "ServerSaveError", resp, "Attempting to display new table" )
        }
      }
    )
  },
  events:{ "click .AddTable.Action":"newTable" }
  } );
  var AppTablesCollection = Backbone.Collection.extend( { 
    pageToken:pageToken, 
    model:AppTablesModel, 
    initialize:function( models, options ) { 
      $.extend( this, options, this);
      this.dburl = "/db/" + self.appDbId;
      this.reorderTablesAction = this.dburl + "?a=QBI_ReorderTables";
      this.deleteTableAction = this.dburl + "?a=QBI_DeleteTable";
      this.expelTableAction = this.dburl + "?a=QBI_ExpelTable";
      this.getTableInfoAction = this.dburl + "?a=QBI_GetTableInfo";
      _.bindAll( this ) 
    },
    comparator:function( model ) { 
      return model.get( "order" )
    },
    doGrowl:function( msg ) {
      $.jGrowl( msg, { theme:"jGrowl-green", pool:1, life:1000 } )
    },
    getNextTableName:function() {
      var highestNum=0;
      var nextName;
      var testNum;
      this.forEach( function( model ) {
        nextName = model.get( "label" );
        if( StringStartsWith( nextName, "Table #" ) ) {
          var testNum = Number( nextName.substr( 7 ) );
          if( !isNaN( testNum ) ) { 
            highestNum=testNum 
          } 
        } 
      } );
      highestNum = Math.max( highestNum+1, this.length+1 );
      return "Table #" + highestNum 
    }, 
    saveOrder:function( reorderMap, selectedIds ) { 
      var numChanged = 0;
      for( var id in reorderMap ) { 
        var table = this.get( id );
        if( typeof table === "undefined" ) { 
          throw new Error( "Error while saving table order: Unknown field " + id ) 
        }
        table.set( { order:reorderMap[id].to }, { silent:true } );
        numChanged++ 
      }
      if( numChanged == 0 ) { 
        return 
      }
      var collection = this;
      var data =  {  };
      collection.each( function( model ){ 
        data[ model.get( "tableDbId" ) ] = model.get( "order" ) 
      } );
      $.post( this.reorderTablesAction, data, function( data, textStatus, resp ) { 
        if( $( getXMLresp( resp.responseText ) ).find( "errcode" ).text(  ) == "0" ) { 
          collection.trigger( "highlightRowsOnDrop",selectedIds );
          collection.doGrowl( "Table order saved" ) 
        } else { collection.trigger( "ServerSaveError", resp, "Attempting to reorder tables" ) 
        } 
      } )
    },
    deleteTable:function( id ) { 
      var tableDbId = this.get( id ).get( "tableDbId" );
      var tableName = this.get( id ).get( "label" );
      var data = { tableDBID:tableDbId, PageToken:this.pageToken };
      var collection = this;
      $.ajax( { 
        url:this.deleteTableAction, 
        cache:false,
        data:data,
        success:function( data, textStatus, resp ) { 
          if( $( getXMLresp( resp.responseText ) ).find( "errcode" ).text(  ) == "0" ){ 
            collection.remove( id, { silent:false } );
            collection.doGrowl( "Table '" + tableName + "' deleted" );
            $( "li#tblMenu_" + tableDbId ).detach(  ) 
          } else {
            collection.trigger( "ServerSaveError", resp, "Attempting to delete table" ) 
          } 
        } 
      } ) 
    },
    moveTable:function( id ) { 
      var tableDbId = this.get( id ).get( "tableDbId" );
      var tableName = this.get( id ).get( "label" );
      var data = { tableDBID:tableDbId, PageToken:this.pageToken };
      var collection = this;
      $.post( this.expelTableAction, data, function( data, textStatus, resp ) { 
        if( $( getXMLresp( resp.responseText ) ).find( "errcode" ).text(  ) == "0" ) { 
          collection.remove( id, { silent:false } );
          collection.doGrowl( "Table '" + tableName + "' moved" );
          $( "li#tblMenu_" + tableDbId ).remove(  ) 
        } else { 
          collection.trigger( "ServerSaveError", resp, "Attempting to move table" ) 
        } 
      } ) 
    } 
  } );
  
  var AppTablesGrid = QB.BaseGridView.extend( { 
    initialize:function( options ) { 
      this.dispatcher=options.dispatcher;
      _.bindAll( this );
      this.collection.bind( "change",this.renderFlag );
      var colModel = [ 
        { name:"id", label:"Id", sorttype:"int", index:"id", align:"left", key:true, cellattr:this.getCellAttr, hidden:true },
        { name:"label", index:"label", label:"Table", align:"left", formatter:this.formatTableName, cellattr:this.getCellAttr, canSort:true },
        { name:"numFields", index:"numFields", label:"Fields", align:"center", width:60, resizable:false, fixed:true, cellattr:this.getCellAttr, canSort:true, sorttype:"int" },
        { name:"relNames", index:"relNames", label:"Related To", align:"left", cellattr:this.getCellAttr, canSort:true },
        { name:"tableDbId", index:"tableDbId", label:"Table DBID", align:"left", cellattr:this.getCellAttr, canSort:true, hidden:true },
        { name:"actions", width:60, label:" ", index:"actions", align:"center", title:false, resizable:false, formatter:this.formatActions, cellattr:this.getCellAttr, fixed:true },
        { name:"order", label:"Order", sorttype:"int", index:"order", align:"right", canSort:true, hidedlg:true, cellattr:this.getCellAttr, hidden:true },
        { name:"isNew", index:"isNew", hidden:true },
        { name:"numEmails", index:"numEmails", label:"numEmails", hidden:true },
        { name:"numRels", index:"numRels", label:"numRels", hidden:true },
        { name:"numForms", index:"numForms", label:"numForms", hidden:true },
        { name:"numReports", index:"numReports", label:"numReports", hidden:true },
        { name:"description", index:"description", label:"description", hidden:true },
      ];
      var gridOptions = { sortable:true, colModel:colModel, multiselect:true, data:this.collection.toJSON(), idPrefix:"" };
      $.extend( this.options, { 
        jqGridOptions:gridOptions, 
        leftAlignedHeaders:[ "label", "relNames" ], 
        stickyHeader:false, 
        autoToolTips:true, 
        el:$( "#appTablesListTable" ), 
        multiDragAndDrop:true, 
        multiOrderOptions:{ 
          helperName:{ singular:"table", plural:"tables" }, 
          helperHintField:"label", 
          orderColumnName:"order", 
          autoScroll:{ element:"#mainBodyDiv" }, 
          reorderComplete:function( reorderMap,selectedIds ) {
            var plainIds=[];
            _.each( reorderMap, function( value, key ) { 
              key=view.getIdFromRowIdAttribute(key);
              plainIds[key] = value
            } );
            view.collection.saveOrder( plainIds, selectedIds );
            view.resizeMe()
          }
        }
      } );
      
      QB.BaseGridView.prototype.initialize.call( this, this.options );
      _.bindAll( this );
      this.initSortDisplay();
      this.initSearchSort();
      this.initBindings();
      var view = this;
      $( "#useTableOrderSortLink" ).click( function() { 
        var cm=view.getColModel();
        view.revertColumnSorting( cm )
      } );
      this.initColumnSorting( this.getColModel(), true )
    },
    initBindings:function() { 
      this.dispatcher.bind( "onSortCol", this.changedGridSort, this );
      this.collection.bind( "add", this.tableAdded );
      this.collection.bind( "highlightRowsOnDrop", this.highlightRowsOnDrop, this );
      this.collection.bind( "changeDefaultSort", this.changedDefaultSort, this )
    },
    highlightRowsOnDrop:function( ids ) {
      this.highlightRows( ids ) 
    },
    initSearchSort:function() { 
      var searchCallback = $.proxy( this.searchGrid, this );
      this.sortname = "order";
      this.sortorder = "asc";
      $( "#tablesSearch" ).bind( "keyup cleared" , searchCallback ) 
    },
    searchGrid:function() { 
      var matchText = $.trim( $( "#tablesSearch" ).val() );
      var srcCriteria;
      if( matchText && matchText == $( "#tablesSearch" ).attr( "placeholder" ) ) { 
        matchText = "" 
      }
      srcCriteria = this.getFilterCriteria( matchText );
      this.dispatcher.trigger( "newSearchCriteria", srcCriteria )
    },
    getFilterCriteria:function( labelStr ) {
      if( labelStr == "" ) {
        return ""
      }
      var baseAndGroup = { groupOp:"AND", rules:[], groups:[] };
      var baseTopSearch = $.extend( true, {}, baseAndGroup );
      var baseLabelRule={field:"label",op:"cn",data:""};
      var currSearch=$.extend(true,{},baseTopSearch);
      var labelCrit=$.extend(true,{},baseLabelRule,{data:labelStr});
      currSearch.rules.push(labelCrit);
      return currSearch
    },
    tableAdded:function(e) { 
      var self=this;
      if(IsIE()){
        _.delay(self.collection.sort,1000)
      } else { 
        self.collection.sort() 
      }
      self.collection.doGrowl("Table added")
    },
    events:{ "click .RowAction.Delete":"deleteTable","click .RowAction.Move":"moveTable" },
    deleteTable:function(e) {
      var target=$(e.target);
      var rowid=target.closest("tr")[0].id;
      var id=this.getIdFromRowIdAttribute(rowid);
      this.confirmDelete(id)
    },
    confirmDelete:function(id) {
      var self=this;
      $("#tableNameToDelete").html(self.collection.get(id).get("label"));
      QB.Dialog.confirm( { 
        id:"dialogDeleteTable",
        contents:"#delete-table-dialog",
        contentType:"selector",
        title:"Delete this Table?",
        focusedButton:null,
        size:"medium",
        confirm:{ 
          text:"Delete Table",
          type:"Danger",
          click:function() { 
            if($("#typeYesField").val()=="YES") { 
              self.doDelete(id);
              $(this).dialog("close")
            }
          }
        }
      } );
      $("#typeYesField").val("");
      $("#typeYesField").focus()
    },
    doDelete:function(id) { 
      this.collection.deleteTable(id)
    },
    moveTable:function(e) { 
      var target=$(e.target);
      var rowid = target.closest( "tr" )[0].id;
      var id=this.getIdFromRowIdAttribute(rowid);
      this.confirmMove(id)
    },
    confirmMove:function(id) { 
      var self=this;
      $("#tableNameToMove").html(self.collection.get(id).get("label"));
      QB.Dialog.confirm( { 
        id:"dialogMoveTable",
        contents:"#move-table-dialog",
        contentType:"selector",
        title:"Move this Table?",
        focusedButton:null,
        size:"medium",
        confirm:{ 
          text:"Move Table",
          type:"Danger",
          click:function() { 
            self.doMove(id);
            $(this).dialog("close")
          }
        }
      } )
    },
    doMove:function(id) { 
      this.collection.moveTable(id)
    },
    formatTableName:function( cellval, options, rowobject ) {
      return ich.formatTableName( { 
        label:rowobject.label,
        description:rowobject.description,
        dbid:rowobject.tableDbId,
        numFields:rowobject.numFields,
        oneField:rowobject.numFields == 1,
        numRels:rowobject.numRels,
        oneRel:rowobject.numRels == 1,
        numEmails:rowobject.numEmails,
        oneEmail:rowobject.numEmails == 1,
        numReports:rowobject.numReports,
        oneReport:rowobject.numReports == 1,
        numForms:rowobject.numForms,
        oneForm:rowobject.numForms == 1,
        hideFromMenuBar:rowobject.hideFromMenuBar,
        tableLocked:rowobject.tablelocked
      },
      true )
    },
    formatActions:function( cellval, options, rowobject ) { 
      var canDelete = !rowobject.tableLocked;
      var canMove = !rowobject.tableLocked;
      return ich.formatActions( { canDelete:canDelete, canMove:canMove }, true )
    },
    getCellAttr:function( rowId, val, rawObject, cm, rdata ) {
      if( cm.name == "label" && rawObject.isNew ) {
        return ' class="Movable AttentionCell "'
      }
      return ' class="Movable "'
    },
    renderFlag:function(model) { 
      this.changedData(model);
      this.options.dispatcher.trigger( "updateGridRow", model.id, model.attributes )
    },
    initSortDisplay:function() { 
      var view=this;
      _.defer( function() { 
        var cm=view.getColModel();
        if( view.sortname != "order" ) { 
          view.enableColumnSorting( cm, true )
        } else { view.enableMultiSortableRows( !view.collection.appSchemaLocked ) 
        }
        view.styleDraggable( view.sortname == "order" )
      } )
    },
    initColumnSorting:function(cm,setting) { 
      _(cm).each( function(it) { 
        if( it.canSort ) {
          it.sortable=setting
        }
      } )
    },
    saveSortCriteria:function( index, sortorder ) {
      this.sortname = index;
      this.sortorder = sortorder
    },
    changedGridSort:function( index, iCol, sortorder ) {
      this.saveSortCriteria( index, sortorder );
      this.enableColumnSorting( this.getColModel, true );
      $( "span.s-ico", this.$el[0].grid.hDiv ).hide();
      $( "span.s-ico", ( "#" + this.$el[0].id+"_" + index ) ).show();
      this.resizeMe()
    },
    styleDraggable:function(on) { 
      if( on && !this.collection.appSchemaLocked ) {
        this.$el.addClass("DragOrderSortable")
      } else { 
        this.$el.removeClass("DragOrderSortable")
      }
    },
    revertColumnSorting:function(cm) { 
      if( $( "#sortModeIsEnabledWarning" ).css( "display" ) == "block" ) { 
        $( "#sortModeIsEnabledWarning" ).hide( "blind" )
      }
      this.enableMultiSortableRows(!this.collection.appSchemaLocked);
      $("span.s-ico",this.$el[0].grid.hDiv).hide();
      this.dispatcher.trigger("newSortSetting",{sortname:"order",sortorder:"asc"});
      this.saveSortCriteria("order","asc");
      this.styleDraggable(true)
    },
    enableColumnSorting:function(cm,on) { 
      if(on) { 
        this.styleDraggable(false);
        if( $("#sortModeIsEnabledWarning").css("display") == "none" && !this.collection.appSchemaLocked ) {
          $("#sortModeIsEnabledWarning").show("blind")
        }
        this.enableMultiSortableRows(false);
        this.initColumnSorting(cm,true)
      } else { 
        this.initColumnSorting(cm,false);
        this.styleDraggable(true);
        this.revertColumnSorting(cm)
      }
    }
  } );
  
  var AppTablesView = Backbone.View.extend( { 
    initialize:function() {
      var self=this;
      this.$("button.Action").button();
      this.grid = new AppTablesGrid( $.extend( {}, this.options, { el:$("#appTablesListTable"), dispatcher:this } ) );
      this.tools = new AppTablesToolbar( $.extend( {}, this.options, { id:"appTablesListToolbar", dispatcher:this } ) );
      setTimeout( function() {
        setupClearables();
        $("input, textarea").placeholder()
      }, 200);
      this.collection.bind( "ServerSaveError", this.reportServerError,this )
    },
    reportServerError:function( resp, title ) { 
      var resp$ = $( getXMLresp( resp.responseText ) );
      var errdetails = resp$.find( "errdetail" ).text();
      var errcode = Number( resp$.find( "errcode" ).text() );
      var errtext = resp$.find( "errtext" ).text();
      if( errtext.length == 0 ) {
        errtext = resp.statusText
      }
      if( errtext.length == 0 ) {
        errtext = resp.responseText
      }
      if( resp.errcode != 0 ) {
        var opts = { 
          title:"Error",
          headline:title,
          size:"medium",
          id:"dialogFieldsServerErrorMessage"
        };
        var errdetail=errdetails;
        if( errdetail ) { 
          opts.contents = errdetail
        } else {
          var errcodestr = errcode ? "error code = " + errcode + " " : "";
          opts.contents = "Operation failed: " + errcodestr + "(" + errtext + ")"
        }
        QB.Dialog.error( opts )
      }
    },
    reportError:function(message) { 
      $.jGrowl( message, { theme:"jGrowl-error" } );
      if( !_.isUndefined( console ) ) {
        console.log(message)
      }
    }
  });
  this.collection=new AppTablesCollection( tableData, {} );
  this.view=new AppTablesView( {
    el:$("#appTablesListSection"),
    addDeleteButton:false,
    addTotalCountElt:false,
    totalsTemplate:"tableTotals",
    totalElt:$("#numTablesLabel"),
    dispatcher:_.clone(Backbone.Events),
    collection:this.collection
  })
};

QB.AppTables.addRelationshipsFromGlobals = function( tableData ) {
  var getRelationshipsAsString = function( rels ) {
    var relsAsString = "";
    var first = true;
    for( var rel in rels ) {
      if( !first ) {
        relsAsString += ", " 
      } else {
        first = false
      }
      relsAsString += rel
    }
    return relsAsString
  };
  var dbid;
  var ri;
  var relTable;
  var rels;
  for ( var i = 0; i<tableData.length; i++ ) {
    dbid = tableData[i].tableDbId;
    rels = {};
    for ( var j = 0; j<rinfo.length; j++ ) {
      ri = rinfo[j];
      if ( ri.mdbid == dbid ){
        relTable = gTableInfo[ri.ddbid].name;
        if ( !rels[relTable] ){
          rels[relTable] = true
        }
      } else {
        if ( ri.ddbid == dbid ){
          relTable = gTableInfo[ri.mdbid].name;
          if ( ri.external ){
            relTable=gCrossAppNames[ri.mdbid] + ":" + relTable
          }
          if ( !rels[relTable] ){
            rels[relTable] = true
          }
        }
      }
    }
    
    for ( var j = 0; j<rdinfo.length; j++ ){
      ri = rdinfo[j];
      if ( ri.mdbid == dbid ){
        relTable = gTableInfo[ri.ddbid].name;
        if ( !rels[relTable] ){
          rels[relTable] = true
        }
      } else {
        if ( ri.ddbid == dbid ){
          relTable = gTableInfo[ri.mdbid].name;
          if ( ri.external ){
            relTable = gCrossAppNames[ri.mdbid] + ":" + relTable
          }
          if ( !rels[relTable] ){
            rels[relTable] = true
          }
        }
      }
    }
    tableData[i].relNames = getRelationshipsAsString( rels )
  }
};
