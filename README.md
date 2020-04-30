liferay-document-and-media-treeview
===================================
Enables a treeview for the Document Library and Web Content. The main purpose on this view is to provide authenticated users an easy way to move and organize their content using a tree structure and the ease of drag and drop.

### Configuration
Add this property to portal-ext.properties when docker on this workspace is not being used
```
# adds treeView to default list, in some cases this is needed to store the last displayStyle set in the preferences and retrieved
dl.display.views=icon,descriptive,list,treeView
```
