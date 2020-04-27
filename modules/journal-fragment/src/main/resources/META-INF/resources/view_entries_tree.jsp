<%@ page import="com.liferay.portal.kernel.dao.search.RowChecker" %>
<%@ page import="com.liferay.journal.service.JournalArticleServiceUtil" %>
<%@ include file="/init.jsp" %> 

<%
int rivetts = 2020042801; // avoid caching on css and js 2
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
        rootFolderLabel: '<%= treeFolderTitle %>',
        checkAllId: '<%= RowChecker.ALL_ROW_IDS %>',
        viewPageBaseURL: '<%= viewArticleURL %>',
        defaultArticleImage: '<%= themeDisplay.getPathThemeImages() + "/file_system/large/article.png" %>',
    });
    
	<% 
		// If current folder is not root (home)
		if (currFolderId != treeFolderId){
	     
		 	// Add ancestors' children 
	        for (Long ancestorId:  ancestorIds){ 
	            
	            // Folders
			    List<JournalFolder> cFolders = JournalFolderServiceUtil.getFolders(scopeGroupId, ancestorId);		    
			    
			    for (JournalFolder cFolder: cFolders){
			        boolean isAncestor = false;
				    if ( (cFolder.getFolderId() == currFolderId ) || (ancestorIds.contains(cFolder.getFolderId())) ){
				       isAncestor = true;
				    }
		        	%>
			    	<portlet:namespace />treeView.addContentFolder({
						id: '<%= String.valueOf(cFolder.getFolderId()) %>',
						label: '<%= cFolder.getName() %>',
						showCheckbox: '<%= JournalFolderPermission.contains(permissionChecker, cFolder, ActionKeys.DELETE) || JournalFolderPermission.contains(permissionChecker, cFolder, ActionKeys.UPDATE) %>',
						rowCheckerId: '<%= String.valueOf(cFolder.getFolderId()) %>',
						rowCheckerName: '<%= JournalFolder.class.getSimpleName() %>',
						parentFolderId: '<%= cFolder.getParentFolderId() %>',
						expanded : <%= isAncestor %>,
	   			    	fullLoaded : <%= isAncestor %>
					});
			    	<%		 
			    }
			    
			    // Articles
			    List<JournalArticle> cArticles = JournalArticleServiceUtil.getArticles(scopeGroupId, ancestorId);	
			    
			    for (JournalArticle cArticle: cArticles){
			         
                    PortletURL tempRowURL = liferayPortletResponse.createRenderURL();

                    tempRowURL.setParameter("mvcPath", "/edit_article.jsp");
					tempRowURL.setParameter("redirect", currentURL);
					tempRowURL.setParameter("referringPortletResource", referringPortletResource);
					tempRowURL.setParameter("groupId", String.valueOf(cArticle.getGroupId()));
					tempRowURL.setParameter("folderId", String.valueOf(cArticle.getFolderId()));
					tempRowURL.setParameter("articleId", cArticle.getArticleId());
                    tempRowURL.setParameter("version", String.valueOf(cArticle.getVersion()));
                    
                    String articleImageURL = cArticle.getArticleImageURL(themeDisplay);

			        %>		        
			        <portlet:namespace />treeView.addContentEntry({
						id : '<%= cArticle.getArticleId() %>',
						label: '<%= cArticle.getTitle(locale) %>',
						showCheckbox: '<%= JournalArticlePermission.contains(permissionChecker, cArticle, ActionKeys.DELETE) || JournalArticlePermission.contains(permissionChecker, cArticle, ActionKeys.EXPIRE) || JournalArticlePermission.contains(permissionChecker, cArticle, ActionKeys.UPDATE) %>',
						rowCheckerId: '<%= String.valueOf(cArticle.getArticleId()) %>',
						rowCheckerName: '<%= JournalArticle.class.getSimpleName() %>',
						parentFolderId: '<%= cArticle.getFolderId() %>',
						previewURL:'<%= Validator.isNotNull(articleImageURL) ? articleImageURL : themeDisplay.getPathThemeImages() + "/file_system/large/article.png" %>',
						viewURL: '<%= tempRowURL %>'
					});
			        <%
			    }
			}
		}
	%>
</aui:script>