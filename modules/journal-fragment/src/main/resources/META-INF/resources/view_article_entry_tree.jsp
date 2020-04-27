<%--
/**
 * Copyright (C) 2005-2014 Rivet Logic Corporation.
 * 
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation; version 3 of the License.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
 * details.
 * 
 * You should have received a copy of the GNU General Public License along with
 * this program; if not, write to the Free Software Foundation, Inc., 51
 * Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 */
--%>

<%@ include file="/init.jsp" %>

<%
JournalArticle article = (JournalArticle)request.getAttribute("view_entries.jsp-article");

String tempRowURL = (String)request.getAttribute("view_entries.jsp-tempRowURL");

String articleImageURL = article.getArticleImageURL(themeDisplay);
%>
<aui:script use="rl-content-tree-view">
<portlet:namespace />treeView.addContentEntry({
	id : '<%= article.getArticleId() %>',
	label: '<%= article.getTitle(locale) %>',
	showCheckbox: '<%= JournalArticlePermission.contains(permissionChecker, article, ActionKeys.DELETE) || JournalArticlePermission.contains(permissionChecker, article, ActionKeys.EXPIRE) || JournalArticlePermission.contains(permissionChecker, article, ActionKeys.UPDATE) %>',
	rowCheckerId: '<%= String.valueOf(article.getArticleId()) %>',
	rowCheckerName: 'rowIds<%= JournalArticle.class.getSimpleName() %>',
	parentFolderId: '<%= article.getFolderId() %>',
	previewURL:'<%= Validator.isNotNull(articleImageURL) ? articleImageURL : themeDisplay.getPathThemeImages() + "/file_system/large/article.png" %>',
	viewURL: '<%= tempRowURL %>'
});
</aui:script>