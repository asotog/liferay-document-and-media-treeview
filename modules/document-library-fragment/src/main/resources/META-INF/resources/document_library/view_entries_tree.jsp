<%@ page import="com.liferay.portal.kernel.dao.search.RowChecker" %>
<%@ page import="com.liferay.document.library.kernel.model.DLFileShortcut" %>
<%@ include file="/document_library/init.jsp" %>

<%
int rivetts = 2020042901; // avoid caching on css and js 2
String MODULE_PATH = "/o/tree-view-frontend";

long repositoryId = GetterUtil.getLong((String)request.getAttribute("view.jsp-repositoryId"));
long folderId = GetterUtil.getLong((String)request.getAttribute("view.jsp-folderId"));
String navigation = ParamUtil.getString(request, "navigation", "home");

// Base URL for view file entry
PortletURL viewFileEntryURL = liferayPortletResponse.createRenderURL();

viewFileEntryURL.setParameter("mvcRenderCommandName", "/document_library/view_file_entry");
viewFileEntryURL.setParameter("redirect", HttpUtil.removeParameter(currentURL, liferayPortletResponse.getNamespace() + "ajax"));

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
	<li data-selectable="true" data-actions="deleteEntries,move,checkout,editTags,download">
		<aui:input cssClass="overlay entry-selector" label="" value="{{rowCheckerId}}" id="{{rowCheckerName}}_{{rowCheckerId}}" name="{{rowCheckerName}}" type="checkbox"  />
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
                        path : 'main.js',
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
@import url("<%= MODULE_PATH %>/css/main.css?t=<%= rivetts %>");
.has-tree-view  .searchcontainer-content .splitter.splitter-spaced,
.has-tree-view  .searchcontainer-content > ul {
    display: none !important;
}
</style>
<aui:script use="rl-content-tree-view">
	<portlet:namespace />treeView = new A.Rivet.ContentTreeView({
		namespace: '<portlet:namespace />',
		treeTarget: A.Rivet.TreeTargetDL,
        repositoryId: '<%= repositoryId %>',
		scopeGroupId: '<%= scopeGroupId %>',
		rootFolderId:'<%= treeFolderId %>',
		currentFolderId: '<%= currFolderId %>',
		ancestorsFoldersIds: <%= ancestorIds %>,
        rootFolderLabel: '<%= treeFolderTitle %>',
        checkAllId: '<%= RowChecker.ALL_ROW_IDS %>',
        viewPageBaseURL: '<%= viewFileEntryURL %>',
        defaultDocumentImagePath: '<%= themeDisplay.getPathThemeImages() + "/file_system/large/" %>',
        shortcutImageURL: '<%= themeDisplay.getPathThemeImages()+"/file_system/large/overlay_link.png" %>'
    });
	<portlet:namespace />treeView.initialLoad();
</aui:script>