<%@ page import="com.liferay.portal.kernel.dao.search.RowChecker" %>
<%@ page import="com.liferay.journal.service.JournalArticleServiceUtil" %>
<%@ include file="/init.jsp" %> 

<%
int rivetts = 2020042901; // avoid caching on css and js 2
String MODULE_PATH = "/o/tree-view-frontend";

// Base URL for view file entry
PortletURL viewArticleURL = liferayPortletResponse.createRenderURL();

viewArticleURL.setParameter("mvcPath", "/edit_article.jsp");
viewArticleURL.setParameter("redirect", HttpUtil.removeParameter(currentURL, liferayPortletResponse.getNamespace() + "ajax"));

List<Long> ancestorIds = new ArrayList<Long>();

// Root will be always the same (home)
long treeFolderId = JournalFolderConstants.DEFAULT_PARENT_FOLDER_ID;
String navigation = ParamUtil.getString(request, "navigation", "home");
long folderId = ParamUtil.getLong(request, "folderId");
String referringPortletResource = ParamUtil.getString(request, "referringPortletResource");
String treeTitle = navigation;
String treeFolderTitle = LanguageUtil.get(request, treeTitle);

// Current folder could be different to root
long currFolderId = treeFolderId;
String currFolderTitle = treeFolderTitle;

if (folderId != JournalFolderConstants.DEFAULT_PARENT_FOLDER_ID){
    
    JournalFolder currFolder = JournalFolderServiceUtil.getFolder(folderId);
    currFolderId = folderId;
    currFolderTitle = currFolder.getName(); 
    
    // We need get all ancestors util root
    List<JournalFolder> ancestors = currFolder.getAncestors();
    
    // We are simulating the root folder as an ancestor
    ancestorIds.add(JournalFolderConstants.DEFAULT_PARENT_FOLDER_ID);
    
    java.util.ListIterator li = ancestors.listIterator(ancestors.size());
    // Iterate in reverse
    while(li.hasPrevious()) {
        JournalFolder f = (JournalFolder) li.previous();
        ancestorIds.add(f.getFolderId());
    }	 
}
%>
<script id="<portlet:namespace />item-selector-template" type="text/x-handlebars-template">
	<c:set var="rowIds" value="<%= RowChecker.ROW_IDS %>" />
	<li data-selectable="true" data-actions="deleteEntries,move,checkout,editTags,download">
		<aui:input cssClass="overlay entry-selector" id="{{rowCheckerName}}_{{rowCheckerId}}" label="" value="{{rowCheckerId}}" name="{{rowCheckerName}}" type="checkbox"  />
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
		searchContainerId: 'articlesSearchContainer',
		containerId: 'articles',
        treeTarget: A.Rivet.TreeTargetJournal,
        scopeGroupId: '<%= scopeGroupId %>',
		rootFolderId:'<%= treeFolderId %>',
		currentFolderId: '<%= currFolderId %>',
		ancestorsFoldersIds: <%= ancestorIds %>,
        rootFolderLabel: '<%= treeFolderTitle %>',
        checkAllId: '<%= RowChecker.ALL_ROW_IDS %>',
		viewPageBaseURL: '<%= viewArticleURL %>',
		emptySearchContainerId: 'articlesEmptyResultsMessage',
        defaultArticleImage: '<%= themeDisplay.getPathThemeImages() + "/file_system/large/article.png" %>',
	});
	<portlet:namespace />treeView.initialLoad();
</aui:script>