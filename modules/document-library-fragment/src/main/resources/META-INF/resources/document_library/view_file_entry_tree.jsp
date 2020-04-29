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
<%@ page import="com.liferay.document.library.kernel.model.DLFileShortcut" %>
<%@ include file="/document_library/init.jsp" %>

<%
FileEntry fileEntry = (FileEntry)request.getAttribute("view_entries.jsp-fileEntry");

FileVersion latestFileVersion = fileEntry.getFileVersion();

if ((user.getUserId() == fileEntry.getUserId()) || permissionChecker.isCompanyAdmin() || permissionChecker.isGroupAdmin(scopeGroupId) || DLFileEntryPermission.contains(permissionChecker, fileEntry, ActionKeys.UPDATE)) {
	latestFileVersion = fileEntry.getLatestFileVersion();
}

FileShortcut fileShortcut = (FileShortcut)request.getAttribute("view_entries.jsp-fileShortcut");
PortletURL rowURL = liferayPortletResponse.createRenderURL();

rowURL.setParameter("mvcRenderCommandName", "/document_library/view_file_entry");
rowURL.setParameter("redirect", HttpUtil.removeParameter(currentURL, liferayPortletResponse.getNamespace() + "ajax"));
rowURL.setParameter("fileEntryId", String.valueOf(fileEntry.getFileEntryId()));

String rowCheckerName = FileEntry.class.getSimpleName();
long rowCheckerId = fileEntry.getFileEntryId();
boolean isFileShortcut = false;
long parentFolderId = fileEntry.getFolderId();

if (fileShortcut != null) {
	rowCheckerName = DLFileShortcut.class.getSimpleName();
	rowCheckerId = fileShortcut.getFileShortcutId();
	isFileShortcut = true;
	parentFolderId = fileShortcut.getFolderId();
}
%>

<aui:script use="rl-content-tree-view">
	<portlet:namespace />treeView.addContentEntry({
		id : '<%= latestFileVersion.getFileEntryId() %>',
		label: '<%= latestFileVersion.getTitle() %>',
		shortcut: <%=isFileShortcut %>,
		showCheckbox: '<%= DLFileEntryPermission.contains(permissionChecker, fileEntry, ActionKeys.DELETE) || DLFileEntryPermission.contains(permissionChecker, fileEntry, ActionKeys.UPDATE) %>',
		rowCheckerId: '<%= String.valueOf(rowCheckerId) %>',
		rowCheckerName: 'rowIds<%= rowCheckerName %>',
		parentFolderId: '<%= parentFolderId %>',
		previewURL:'<%= DLURLHelperUtil.getThumbnailSrc(fileEntry, latestFileVersion, themeDisplay) %>',
		viewURL: '<%= rowURL.toString() %>'
	});
</aui:script>