<%@ page import="com.liferay.portal.kernel.dao.search.RowChecker" %>
<%@ page import="com.liferay.document.library.kernel.model.DLFileShortcut" %>
<%@ include file="/document_library/init.jsp" %>

<%
int rivetts = 20200423; // avoid caching on css and js 2
String MODULE_PATH = "/o/document-library-web";

long repositoryId = GetterUtil.getLong((String)request.getAttribute("view.jsp-repositoryId"));
long folderId = GetterUtil.getLong((String)request.getAttribute("view.jsp-folderId"));
String navigation = ParamUtil.getString(request, "navigation", "home");

// Base URL for view file entry
PortletURL viewFileEntryURL = renderResponse.createRenderURL();
// viewFileEntryURL.setParameter("struts_action", "/document_library/view_file_entry");
// viewFileEntryURL.setParameter("redirect", HttpUtil.removeParameter(currentURL, liferayPortletResponse.getNamespace() + "ajax"));

List<Long> ancestorIds = new ArrayList<Long>();

// Root will be always the same (home)

long treeFolderId = DLFolderConstants.DEFAULT_PARENT_FOLDER_ID;
String treeFolderTitle = LanguageUtil.get(request, navigation);

// Current folder could be different to root
long currFolderId = treeFolderId;
String currFolderTitle = treeFolderTitle;

if (folderId != DLFolderConstants.DEFAULT_PARENT_FOLDER_ID){
    
    Folder currFolder = DLAppServiceUtil.getFolder(folderId);
    currFolderId = folderId;
    currFolderTitle = currFolder.getName(); 
    
        // We need get all ancestors util root
    List<Folder> ancestors = currFolder.getAncestors();
        
    // We are simulating the root folder as an ancestor
    ancestorIds.add(DLFolderConstants.DEFAULT_PARENT_FOLDER_ID);
    
    java.util.ListIterator li = ancestors.listIterator(ancestors.size());
    // Iterate in reverse
    while(li.hasPrevious()) {
        Folder f = (Folder) li.previous();
        ancestorIds.add(f.getFolderId());
    }	 
}
%>
<script id="<portlet:namespace />item-selector-template" type="text/x-handlebars-template">
	<c:set var="rowIds" value="<%= RowChecker.ROW_IDS %>" />
	<li data-selectable="true">
		<aui:input cssClass="overlay entry-selector" label="" value="{{rowCheckerId}}" name="{{rowCheckerName}}" type="checkbox"  />
	</li>
</script>
<script>
(function() {
    var MODULE_PATH = '<%= MODULE_PATH %>';
    AUI().applyConfig({
        groups : {
            'rl-content-tree-view' : {
                base : MODULE_PATH + '/js/',
                combine : Liferay.AUI.getCombine(),
                modules : {
                    'rl-content-tree-view' : {
                        path : 'rl-content-tree-view.js',
                        requires : []
					}
                },
                root : MODULE_PATH + '/js/'
            },
        }
    });
})();
</script>
<style type="text/css">
@import url("<%= MODULE_PATH %>/css/rl-content-tree-view.css?t=<%= rivetts %>");
</style>
<aui:script use="rl-content-tree-view">
	<portlet:namespace />treeView = new A.Rivet.ContentTreeView({
		namespace: '<portlet:namespace />',
		searchContainer: Liferay.SearchContainer.get("<portlet:namespace />entries"),
        treeTarget: A.Rivet.TreeTargetDL,
        repositoryId: '<%= repositoryId %>',
        scopeGroupId: '<%= scopeGroupId %>',
        rootFolderId:'<%= treeFolderId %>',
        rootFolderLabel: '<%= treeFolderTitle %>',
        checkAllId: '<%= RowChecker.ALL_ROW_IDS %>',
        viewPageBaseURL: '<%= viewFileEntryURL %>',
        defaultDocumentImagePath: '<%= themeDisplay.getPathThemeImages() + "/file_system/large/" %>',
        shortcutImageURL: '<%= themeDisplay.getPathThemeImages()+"/file_system/large/overlay_link.png" %>'
    });
    
	<% 
		// If current folder is not root (home)
		if (currFolderId != treeFolderId){
	     
		 	// Add ancestors' children 
	        for (Long ancestorId:  ancestorIds){ 
	            
	            // Folders
			    List<Folder> cFolders = DLAppServiceUtil.getFolders(repositoryId, ancestorId);		    
			    
			    for (Folder cFolder: cFolders){
			        boolean isAncestor = false;
				    if ( (cFolder.getFolderId() == currFolderId ) || (ancestorIds.contains(cFolder.getFolderId())) ){
				       isAncestor = true;
				    }
		        	%>
			    	<portlet:namespace />treeView.addContentFolder({
						id: '<%= cFolder.getFolderId() %>',
						label: '<%= cFolder.getName() %>',
						showCheckbox: '<%= DLFolderPermission.contains(permissionChecker, cFolder, ActionKeys.DELETE) || DLFolderPermission.contains(permissionChecker, cFolder, ActionKeys.UPDATE) %>',
						rowCheckerId: '<%= String.valueOf(cFolder.getFolderId()) %>',
						rowCheckerName: '<%= Folder.class.getSimpleName() %>',
						parentFolderId: '<%= cFolder.getParentFolderId() %>',
						expanded : <%= isAncestor %>,
	   			    	fullLoaded : <%= isAncestor %>
					});
			    	<%		 
			    }
			    
			    // Files
			    List<Object> items = DLAppServiceUtil.getFileEntriesAndFileShortcuts(repositoryId, ancestorId, WorkflowConstants.STATUS_ANY, QueryUtil.ALL_POS, QueryUtil.ALL_POS);	
			    
			    for (Object item: items){
			         
			        FileEntry fileEntry = null;
			        DLFileShortcut fileShortcut = null;
			        String rowCheckerName = "";
			        String rowCheckerId = "";
			        boolean isShortcut = false;
			        long parentFolderId = 0;
			        
			        if (item instanceof FileEntry) {
			            fileEntry = (FileEntry)item;
			            fileEntry = fileEntry.toEscapedModel();
			            rowCheckerName = FileEntry.class.getSimpleName();
				        rowCheckerId = String.valueOf(fileEntry.getFileEntryId());
				        parentFolderId = fileEntry.getFolderId();
				       
			        }
			        else {		            
			            fileShortcut = (DLFileShortcut)item;
			            fileShortcut = fileShortcut.toEscapedModel();
			        	fileEntry = DLAppLocalServiceUtil.getFileEntry(fileShortcut.getToFileEntryId());
			        	fileEntry = fileEntry.toEscapedModel();
			        	rowCheckerName = DLFileShortcut.class.getSimpleName();
			        	rowCheckerId = String.valueOf(fileShortcut.getFileShortcutId());
			        	isShortcut = true;
			        	parentFolderId = fileShortcut.getFolderId();
			        }		        		        
			        FileVersion latestFileVersion = fileEntry.getFileVersion();
			        PortletURL tempRowURL = liferayPortletResponse.createRenderURL();
					tempRowURL.setParameter("struts_action", "/document_library/view_file_entry");
					tempRowURL.setParameter("redirect", HttpUtil.removeParameter(currentURL, liferayPortletResponse.getNamespace() + "ajax"));
					tempRowURL.setParameter("fileEntryId", String.valueOf(latestFileVersion.getFileEntryId()));
			        %>

			        <portlet:namespace />treeView.addContentEntry({
			        	id : '<%= latestFileVersion.getFileEntryId() %>',
			        	label: '<%= latestFileVersion.getTitle() %>',
			        	shortcut: <%= isShortcut %>,
			        	showCheckbox: '<%= DLFileEntryPermission.contains(permissionChecker, fileEntry, ActionKeys.DELETE) || DLFileEntryPermission.contains(permissionChecker, fileEntry, ActionKeys.UPDATE) %>',
			        	rowCheckerId: '<%= String.valueOf(rowCheckerId) %>',
			        	rowCheckerName: '<%= rowCheckerName %>',
			        	parentFolderId: '<%= parentFolderId %>',
			        	previewURL:'<%= DLUtil.getThumbnailSrc(fileEntry, latestFileVersion, fileShortcut, themeDisplay) %>',
			        	viewURL: '<%= tempRowURL %>'  	
			        });
			        <%
			    }
			}
		}
	%>
</aui:script>