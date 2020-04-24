<%@ page import="com.liferay.frontend.taglib.clay.servlet.taglib.util.ViewTypeItemList" %>
<%@ page import="com.liferay.frontend.taglib.clay.servlet.taglib.util.ViewTypeItem" %>
<%@ include file="/document_library/init.jsp" %>

<%
	ViewTypeItemList viewsList = dlAdminManagementToolbarDisplayContext.getViewTypes();
	String _selectedType = ParamUtil.getString(request, "displayStyle");
	String TREE_VIEW = "treeView";
	ViewTypeItem viewTypeItem = new ViewTypeItem();
	viewTypeItem.setIcon("pages-tree");
	viewTypeItem.setLabel("Tree");
	PortletURL treeViewURL = renderResponse.createRenderURL();
	long folderId = ParamUtil.getLong(request, "folderId");
	String navigation = ParamUtil.getString(request, "navigation", "home");
	treeViewURL.setParameter("mvcRenderCommandName", "/document_library/view");
	treeViewURL.setParameter("folderId", String.valueOf(folderId));
	treeViewURL.setParameter("navigation", "home");
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

<div class="<%= treeViewToolBarCss %>">
	<clay:management-toolbar
		actionDropdownItems="<%= dlAdminManagementToolbarDisplayContext.getActionDropdownItems() %>"
		clearResultsURL="<%= dlAdminManagementToolbarDisplayContext.getClearResultsURL() %>"
		componentId="<%= dlAdminManagementToolbarDisplayContext.getComponentId() %>"
		creationMenu="<%= dlAdminManagementToolbarDisplayContext.getCreationMenu() %>"
		defaultEventHandler='<%= renderResponse.getNamespace() + "DocumentLibrary" %>'
		disabled="<%= dlAdminManagementToolbarDisplayContext.isDisabled() %>"
		filterDropdownItems="<%= dlAdminManagementToolbarDisplayContext.getFilterDropdownItems() %>"
		filterLabelItems="<%= dlAdminManagementToolbarDisplayContext.getFilterLabelItems() %>"
		infoPanelId="infoPanelId"
		itemsTotal="<%= dlAdminManagementToolbarDisplayContext.getTotalItems() %>"
		searchActionURL="<%= String.valueOf(dlAdminManagementToolbarDisplayContext.getSearchURL()) %>"
		searchContainerId="entries"
		selectable="<%= dlAdminManagementToolbarDisplayContext.isSelectable() %>"
		showInfoButton="<%= true %>"
		showSearch="<%= dlAdminManagementToolbarDisplayContext.isShowSearch() %>"
		sortingOrder="<%= dlAdminManagementToolbarDisplayContext.getSortingOrder() %>"
		sortingURL="<%= String.valueOf(dlAdminManagementToolbarDisplayContext.getSortingURL()) %>"
		supportsBulkActions="<%= true %>"
		viewTypeItems="<%= viewsList %>"
		/>
</div>