<%--
/**
 * Copyright (c) 2000-present Liferay, Inc. All rights reserved.
 *
 * The contents of this file are subject to the terms of the Liferay Enterprise
 * Subscription License ("License"). You may not use this file except in
 * compliance with the License. You can obtain a copy of the License by
 * contacting Liferay, Inc. See the License for the specific language governing
 * permissions and limitations under the License, including but not limited to
 * distribution rights of the Software.
 *
 *
 *
 */
--%>
<%-- BEGIN: Rivet Logic --%>
<%@ page import="com.liferay.frontend.taglib.clay.servlet.taglib.util.ViewTypeItem" %>
<%-- END: Rivet Logic --%>

<%@ include file="/init.jsp" %>

<%
JournalManagementToolbarDisplayContext journalManagementToolbarDisplayContext = null;

if (!journalDisplayContext.isSearch() || journalDisplayContext.isWebContentTabSelected()) {
	journalManagementToolbarDisplayContext = new JournalManagementToolbarDisplayContext(liferayPortletRequest, liferayPortletResponse, request, journalDisplayContext, trashHelper);
}
else if (journalDisplayContext.isVersionsTabSelected()) {
	journalManagementToolbarDisplayContext = new JournalArticleVersionsManagementToolbarDisplayContext(liferayPortletRequest, liferayPortletResponse, request, journalDisplayContext, trashHelper);
}
else if (journalDisplayContext.isCommentsTabSelected()) {
	journalManagementToolbarDisplayContext = new JournalArticleCommentsManagementToolbarDisplayContext(liferayPortletRequest, liferayPortletResponse, request, journalDisplayContext, trashHelper);
}
else {
	journalManagementToolbarDisplayContext = new JournalManagementToolbarDisplayContext(liferayPortletRequest, liferayPortletResponse, request, journalDisplayContext, trashHelper);
}

String title = journalDisplayContext.getFolderTitle();

if (Validator.isNotNull(title)) {
	renderResponse.setTitle(journalDisplayContext.getFolderTitle());
}
%>

<%-- BEGIN: Rivet Logic --%>
<%
	List<ViewTypeItem> viewsList = journalManagementToolbarDisplayContext.getViewTypeItems();
	String _selectedType = ParamUtil.getString(request, "displayStyle");
	String TREE_VIEW = "treeView";
	ViewTypeItem viewTypeItem = new ViewTypeItem();
	viewTypeItem.setIcon("pages-tree");
	viewTypeItem.setLabel("Tree");
	PortletURL treeViewURL = renderResponse.createRenderURL();
	long folderId = ParamUtil.getLong(request, "folderId");
	String navigation = ParamUtil.getString(request, "navigation", "home");
	treeViewURL.setParameter("folderId", String.valueOf(folderId));
	treeViewURL.setParameter("navigation", "home");
	treeViewURL.setParameter("delta", "200");
	viewTypeItem.setHref(treeViewURL, "displayStyle", TREE_VIEW);
	if (Validator.isNotNull(_selectedType)) {
		if (Objects.equals(_selectedType, TREE_VIEW)) {
			viewsList.get(0).setActive(false);
			viewTypeItem.setActive(true);
		}	
	}

	viewsList.add(viewTypeItem);
	String treeViewToolBarCss = _selectedType.equals(TREE_VIEW) ? "treeview-toolbar" : "";
%>
<%-- END: Rivet Logic --%>

<portlet:actionURL name="/journal/restore_trash_entries" var="restoreTrashEntriesURL" />

<liferay-trash:undo
	portletURL="<%= restoreTrashEntriesURL %>"
/>

<clay:navigation-bar
	inverted="<%= true %>"
	navigationItems='<%= journalDisplayContext.getNavigationBarItems("web-content") %>'
/>

<div class="<%=treeViewToolBarCss %>">
	<clay:management-toolbar
		displayContext="<%= journalManagementToolbarDisplayContext %>" viewTypeItems="<%= viewsList %>"
	/>
</div>

<liferay-frontend:component
	componentId="<%= journalManagementToolbarDisplayContext.getDefaultEventHandler() %>"
	context="<%= journalManagementToolbarDisplayContext.getComponentContext() %>"
	module="js/ManagementToolbarDefaultEventHandler.es"
/>

<div class="closed container-fluid-1280 sidenav-container sidenav-right" id="<portlet:namespace />infoPanelId">
	<c:if test="<%= journalDisplayContext.isShowInfoButton() %>">
		<liferay-portlet:resourceURL copyCurrentRenderParameters="<%= false %>" id="/journal/info_panel" var="sidebarPanelURL">
			<portlet:param name="folderId" value="<%= String.valueOf(journalDisplayContext.getFolderId()) %>" />
		</liferay-portlet:resourceURL>

		<liferay-frontend:sidebar-panel
			resourceURL="<%= sidebarPanelURL %>"
			searchContainerId="articles"
		>
			<liferay-util:include page="/info_panel.jsp" servletContext="<%= application %>" />
		</liferay-frontend:sidebar-panel>
	</c:if>

	<div class="sidenav-content">
		<c:if test="<%= !journalDisplayContext.isNavigationMine() && !journalDisplayContext.isNavigationRecent() %>">
			<liferay-site-navigation:breadcrumb
				breadcrumbEntries="<%= JournalPortletUtil.getPortletBreadcrumbEntries(journalDisplayContext.getFolder(), request, journalDisplayContext.getPortletURL()) %>"
			/>
		</c:if>

		<aui:form action="<%= journalDisplayContext.getPortletURL() %>" method="get" name="fm">
			<aui:input name="<%= ActionRequest.ACTION_NAME %>" type="hidden" />
			<aui:input name="redirect" type="hidden" value="<%= currentURL %>" />
			<aui:input name="groupId" type="hidden" value="<%= scopeGroupId %>" />
			<aui:input name="newFolderId" type="hidden" />

			<c:choose>
				<c:when test="<%= !journalDisplayContext.isSearch() %>">
					<liferay-util:include page="/view_entries.jsp" servletContext="<%= application %>" />
				</c:when>
				<c:otherwise>

					<%
					String[] tabsNames = new String[0];
					String[] tabsValues = new String[0];

					if (journalDisplayContext.hasResults()) {
						String tabName = StringUtil.appendParentheticalSuffix(LanguageUtil.get(request, "web-content"), journalDisplayContext.getTotalItems());

						tabsNames = ArrayUtil.append(tabsNames, tabName);
						tabsValues = ArrayUtil.append(tabsValues, "web-content");
					}

					if (journalDisplayContext.hasVersionsResults()) {
						String tabName = StringUtil.appendParentheticalSuffix(LanguageUtil.get(request, "versions"), journalDisplayContext.getVersionsTotal());

						tabsNames = ArrayUtil.append(tabsNames, tabName);
						tabsValues = ArrayUtil.append(tabsValues, "versions");
					}

					if (journalDisplayContext.hasCommentsResults()) {
						String tabName = StringUtil.appendParentheticalSuffix(LanguageUtil.get(request, "comments"), journalDisplayContext.getCommentsTotal());

						tabsNames = ArrayUtil.append(tabsNames, tabName);
						tabsValues = ArrayUtil.append(tabsValues, "comments");
					}
					%>

					<liferay-ui:tabs
						names="<%= StringUtil.merge(tabsNames) %>"
						portletURL="<%= journalDisplayContext.getPortletURL() %>"
						tabsValues="<%= StringUtil.merge(tabsValues) %>"
					/>

					<c:choose>
						<c:when test="<%= journalDisplayContext.isWebContentTabSelected() %>">
							<liferay-util:include page="/view_entries.jsp" servletContext="<%= application %>" />
						</c:when>
						<c:when test="<%= journalDisplayContext.isVersionsTabSelected() %>">
							<liferay-util:include page="/view_versions.jsp" servletContext="<%= application %>" />
						</c:when>
						<c:when test="<%= journalDisplayContext.isCommentsTabSelected() %>">
							<liferay-util:include page="/view_comments.jsp" servletContext="<%= application %>" />
						</c:when>
						<c:otherwise>
							<liferay-util:include page="/view_entries.jsp" servletContext="<%= application %>" />
						</c:otherwise>
					</c:choose>
				</c:otherwise>
			</c:choose>
		</aui:form>
	</div>
</div>