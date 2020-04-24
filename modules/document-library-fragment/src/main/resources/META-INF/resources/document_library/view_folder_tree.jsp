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

<%@ include file="/document_library/init.jsp" %>

<%
Folder folder = (Folder)request.getAttribute("view_entries.jsp-folder");

PortletURL tempRowURL = (PortletURL)request.getAttribute("view_entries.jsp-tempRowURL");
%> 

<aui:script use="rl-content-tree-view">
	<portlet:namespace />treeView.addContentFolder({
		id: '<%= folder.getFolderId() %>',
		label: '<%= folder.getName() %>',
		showCheckbox: '<%= DLFolderPermission.contains(permissionChecker, folder, ActionKeys.DELETE) || DLFolderPermission.contains(permissionChecker, folder, ActionKeys.UPDATE) %>',
		rowCheckerId: '<%= String.valueOf(folder.getFolderId()) %>',
		rowCheckerName: 'rowIds<%= Folder.class.getSimpleName() %>',
		parentFolderId: '<%= folder.getParentFolderId() %>',
		expanded : false,
   		fullLoaded : false
	});
</aui:script>
