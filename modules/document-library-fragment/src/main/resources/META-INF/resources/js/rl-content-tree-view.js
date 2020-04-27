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

YUI.add(
  "rl-content-tree-view",
  function (A) {
    A.namespace("Rivet");

    A.Rivet.TreeTargetJournal = "journal";
    A.Rivet.TreeTargetDL = "documentLibrary";

    var ENTRIES_CONTAINER = "entries";
    var ENTRIES_SEARCH_CONTAINER = "entriesSearchContainer";
    var BOUNDING_BOX = "boundingBox";
    var TREE_NODE = "tree-node";
    var NODE_SELECTOR = "." + TREE_NODE;
    var NODE_CHECKBOX_SELECTOR = ".tree-node-checkbox-container";
    var PARENT_NODE = "parentNode";
    var NODE = "node";
    var NODE_ATTR_ID = "id";
    var NODE_ATTR_ENTRY_ID = "entryId";
    var NODE_ATTR_IS_FOLDER = "isFolder";
    var NODE_ATTR_PARENT_FOLDER = "parentFolderId";
    var NODE_ATTR_FULL_LOADED = "fullLoaded";
    var NODE_ATTR_PREVIEW_IMG_PREF = "pvTreeImage";
    var NODE_ATTR_PREVIEW_IMG_NODE = "previewNode";
    var NODE_ATTR_PREVIEW_URL = "previewURL";
    var NODE_ATTR_SHORTCUT = "shortcut";
    var NODE_TYPE_CHECKBOX = "check";
    var TPT_DELIM_OPEN = "{{";
    var TPT_DELIM_CLOSE = "}}";
    var TPT_ENCODED_DELIM_OPEN = "&#x7b;&#x7b;";
    var TPT_ENCODED_DELIM_CLOSE = "&#x7d;&#x7d;";
    var TPL_PREVIEW_NODE =
      '<img src="{previewFileURL}" id="{imgId}" class="treePreviewImg"/>';
    var TPL_SHORTCUT_PREVIEW_NODE =
      '<img src="{shortcutImageURL}" class="shortcut-icon img-polaroid" alt="Shortcut">';
    var WORKFLOW_STATUS_ANY = -1;
    var QUERY_ALL = -1;
    var REG_EXP_GLOBAL = "g";
    var SHORTCUT_LABEL = "shortcut-tree-node-label";
    var TOOLTIP_HELPER_PROPERTY = "helper";
    var TOOLTIP_HELPER_LABEL = ".tree-drag-helper-label";
    var APPEND = "append";

    A.Rivet.ContentTreeView = A.Base.create(
      "rl-content-tree-view",
      A.Base,
      [],
      {
        ns: null,
        treeTarget: null,
        repository: null,
        scopeGroup: null,
        contentTree: null,
        contentRoot: null,
        compiledItemSelectorTemplate: null,
        hiddenFieldsBox: null,
        previewBoundingBox: null,
        defaultDocumentImagePath: null,
        defaultArticleImage: null,
        viewPageBaseURL: null,
        shortcutNode: null,

        initializer: function () {
          var instance = this;
          // show container when js is ready to start rendering tree
          var hasTreeViewElement = A.one('.has-tree-view');
          if (!hasTreeViewElement) {
            return;
          }
          A.one('.has-tree-view').removeClass('d-none');

          this.ns = this.get("namespace");
          this.scopeGroupId = this.get("scopeGroupId");
          this._getTargetAttributes();
          this.viewPageBaseURL = this.get("viewPageBaseURL");
          this.defaultDocumentImagePath = this.get("defaultDocumentImagePath");
          this.defaultArticleImage = this.get("defaultArticleImage");
          this.mouseIsDown = false;
          this.checkedArray = [];
          this.loadingMaskMove;
          this.q = null;
          this.mouseIsDown = false;

          var folderId = this.get("rootFolderId");
          var folderLabel = this.get("rootFolderLabel");
          var checkAllEntriesId = this.get("checkAllId");
          var shortcutImageURL = this.get("shortcutImageURL");

          var instance = this;
          var boundingBoxId = 'rl-tree-container';
          var hiddenBoundingBoxId = boundingBoxId + "HiddenFields";
          var previewBoundingBoxId = boundingBoxId + "Preview";

          if (!A.one("#" + this.ns + ENTRIES_CONTAINER)) {
            Liferay.once(`${this.ns}${ENTRIES_CONTAINER}:registered`, function() {
              window.setTimeout(() => instance.initializer(), 50);
            });
            return;
          }
          var searchContainerElement = A.one("#" + this.ns + ENTRIES_SEARCH_CONTAINER);
          var entriesContainer = A.one("#" + this.ns + ENTRIES_CONTAINER);
          searchContainerElement.append(
            '<div id="' +
              previewBoundingBoxId +
              '" class="rl-tree-preview"></div>'
          );
          entriesContainer.append(
            '<div id="' + boundingBoxId + '" class="sheet bounding-box"></div>'
          );
          searchContainerElement.append(
            '<div id="' + hiddenBoundingBoxId + '" class="hidden-bounding-box"></div>'
          );

          this.hiddenFieldsBox = searchContainerElement.one('.hidden-bounding-box').hide();
          this.previewBoundingBox = searchContainerElement.one('.rl-tree-preview');

          this.shortcutNode = A.Lang.sub(TPL_SHORTCUT_PREVIEW_NODE, {
            shortcutImageURL: shortcutImageURL,
          });

          this.contentTree = new A.TreeViewDD({
            boundingBox: '#' + boundingBoxId,
            children: [
              {
                id: folderId,
                label: folderLabel,
                lazyLoad: false,
                leaf: false,
                expanded: true,
              },
            ],
            after: {
              "drop:hit": A.bind(instance._afterDropHitHandler, this),
              "drag:start": A.bind(instance._dragStartHandler, this),
            },
            on: {
              "drop:hit": A.bind(instance._dropHitHandler, this),
              "drag:mouseDown": A.bind(instance._mouseDown, this),
              "drag:mouseup": A.bind(instance._mouseUp, this),
            },
          }).render();

          A.one('#' + boundingBoxId).addClass('sheet');

          this.contentRoot = this.contentTree.getNodeById(folderId);
          this.contentRoot.set(NODE_ATTR_IS_FOLDER, true);
          this.contentRoot.set(NODE_ATTR_FULL_LOADED, true);

          // Adding this event on this way because the click event seems on creation seems to be on tree level
          var boundingBox = this.contentTree.get(BOUNDING_BOX);
          boundingBox.delegate(
            "click",
            A.bind(instance._clickHandler, this),
            NODE_SELECTOR
          );
          boundingBox.delegate(
            "mouseover",
            A.bind(instance._mouseOverHandler, this),
            NODE_SELECTOR
          );

        //template
        var itemSelectorTemplate = A.one(
          "#" + this.ns + "item-selector-template"
        ).get("innerHTML");

        // some template tokens get lost because encoding:
        itemSelectorTemplate = itemSelectorTemplate.replace(
          new RegExp(TPT_ENCODED_DELIM_OPEN, REG_EXP_GLOBAL),
          TPT_DELIM_OPEN
        );
        itemSelectorTemplate = itemSelectorTemplate.replace(
          new RegExp(TPT_ENCODED_DELIM_CLOSE, REG_EXP_GLOBAL),
          TPT_DELIM_CLOSE
        );

        // compiles template
        this.compiledItemSelectorTemplate = A.Handlebars.compile(
          itemSelectorTemplate
        );

          // loading mask when moving multiple entries
          this.loadingMaskMove = new A.LoadingMask({
            "strings.loading": "Moving Files",
            target: A.one("#" + this.ns + ENTRIES_SEARCH_CONTAINER),
          });

          Liferay.fire('rl-content-tree-view:initialized');

          // destroy DOM before navigate
          Liferay.once('beforeNavigate', function(event) {
            entriesContainer.all(`#${boundingBoxId}`).remove();
            searchContainerElement.all(`#${previewBoundingBoxId}`).remove();
            searchContainerElement.all(`#${hiddenBoundingBoxId}`).remove();
          });
        },


        addContentFolder: function (newNodeConfig, parentNode) {
          var instance = this;
          if (!this.contentTree) {
            Liferay.on('rl-content-tree-view:initialized', function() {
              instance.addContentFolder(newNodeConfig, parentNode);
            });
            return;
          }
          this._addContentNode(newNodeConfig, parentNode, true);
        },

        addContentEntry: function (newNodeConfig, parentNode) {
          var instance = this;
          if (!this.contentTree) {
            Liferay.on('rl-content-tree-view:initialized', function() {
              instance.addContentEntry(newNodeConfig, parentNode);
            });
            return;
          }
          newNodeConfig.expanded = false;
          newNodeConfig.fullLoaded = true;
          this._addContentNode(newNodeConfig, parentNode, false);
        },

        _getTargetAttributes: function () {
          this.treeTarget = this.get("treeTarget");
          if (this._isDLTarget()) {
            this.repository = this.get("repositoryId");
          }
        },

        _isDLTarget: function () {
          return this.treeTarget === A.Rivet.TreeTargetDL;
        },

        _mouseDown: function (event) {
          this.mouseIsDown = true;
        },

        _mouseUp: function (event) {
          this.mouseIsDown = false;
        },

        _dragStartHandler: function (event) {
          var self = this;
          event.target.after("dragNodeChange", function () {
            if (!self.mouseIsDown) {
              self.contentTree.get(TOOLTIP_HELPER_PROPERTY).hide();
            }
          });

          var dragNode = event.target.get(NODE);
          // if the dragging node was checked
          if (dragNode.hasClass("tree-node-checked")) {
            // override the helper label when moving multiple elements
            if (this.checkedArray.length && this.checkedArray.length > 1) {
              var helperLabel = A.one(TOOLTIP_HELPER_LABEL);
              helperLabel.html(
                "Move " + this.checkedArray.length + " elements"
              );
            }
          } else {
            // the dragging node was not checked, reset checked array
            this._resetCheckedArray();
          }
        },

        _dropHitHandler: function (event) {
          var self = this;
          var dropNode, dragNode;
          var dropTreeNode, dragTreeNode;

          // get the dropNode according the action
          if (self.contentTree.dropAction === APPEND) {
            // when appending, the drop node is the target drop element
            dropNode = event.drop.get(NODE).get(PARENT_NODE);
            dropTreeNode = dropNode.getData(TREE_NODE);
          } else {
            // when inserting above or below, the parent is the parent of the drop element
            dropNode = event.drop.get(NODE).get(PARENT_NODE);
            // 'the parent of the parent' can be found by querying the closest 'li' of the drop element
            dropNode = dropNode.ancestor("li");
            dropTreeNode = dropNode.getData(TREE_NODE);
          }

          if (!(dropTreeNode instanceof A.TreeNode)) {
            event.preventDefault();
          } else {
            // moving multiple elements
            if (self.checkedArray.length && self.checkedArray.length > 1) {
              // create async queue
              self.q = new A.AsyncQueue();
              for (var i = 0; i < self.checkedArray.length; i++) {
                dragNode = A.one("#" + self.checkedArray[i]);

                if (dragNode) {
                  dragTreeNode = dragNode.getData(TREE_NODE);
                  // add a callback for every element being moved
                  self.q.add({
                    fn: self._moveSingleElement.bind(self), // fn to trigger
                    args: [
                      dragTreeNode,
                      dropTreeNode,
                      dragTreeNode.get(PARENT_NODE),
                    ], // arguments: the third arg is needed
                    // because the AUI TreeView's _afterDropHit is excecuted before the async queue. Since this args are passed
                    // by reference, the AUI _afterDropHit changes the parent, creating inconsistency in _moveContentNode.
                  });
                }
              }

              // finall callback, when moving all elements is done
              self.q.add(
                function () {
                  // hide the loading mask
                  this.loadingMaskMove.hide();
                  // hide the helper
                  this.contentTree.get(TOOLTIP_HELPER_PROPERTY).hide();
                }.bind(self)
              ); // bind the 'this' object to this callback

              // Starting async queue, first show the loading mask
              self.loadingMaskMove.show();
              // Run the async queue
              self.q.run();
            } else {
              // moving single element
              dragNode = event.drag.get(NODE).get(PARENT_NODE);
              dragTreeNode = dragNode.getData(TREE_NODE);
              self._moveSingleElement(dragTreeNode, dropTreeNode);
            }
          }
        },

        _moveSingleElement: function (
          dragTreeNode,
          dropTreeNode,
          dragParentNode
        ) {
          // if the parent's element is checked, don't move it. By moving the parent, the children
          // are moved automatically, so it's not needed.
          if (!this._isChecked(dragParentNode)) {
            this._moveContentNode(dragTreeNode, dropTreeNode, dragParentNode);
          }
        },

        _afterDropHitHandler: function (event) {
          if (this.contentTree.dropAction === APPEND) {
            var dropNode = event.drop.get(NODE).get(PARENT_NODE);
            var dropTreeNode = dropNode.getData(TREE_NODE);
            if (!this._isFullLoaded(dropTreeNode)) {
              dropTreeNode.empty();
              this._getChildren(dropTreeNode, this);
            }
          }
        },

        _moveContentNode: function (node, target, dragParentNode) {
          if (!this._isFolder(target)) {
            target = target.get(PARENT_NODE);
          }

          // use dragParentNode if provided, if not get it from the element being moved.
          var parentNode = dragParentNode || node.get(PARENT_NODE);
          if (parentNode.get(NODE_ATTR_ID) != target.get(NODE_ATTR_ID)) {
            if (this._isDLTarget()) {
              this._moveDLContentNode(node, target);
            } else {
              this._moveJournalContentNode(node, target);
            }
          }

          boundingBox = this.contentTree.get(BOUNDING_BOX);
          boundingBox.detach("click");
          boundingBox.detach("mouseover");
          boundingBox.delegate(
            "click",
            A.bind(this._clickHandler, this),
            NODE_SELECTOR
          );
          boundingBox.delegate(
            "mouseover",
            A.bind(this._mouseOverHandler, this),
            NODE_SELECTOR
          );
          this.contentTree.bindUI();
        },

        _moveDLContentNode: function (node, target) {
          if (this._isFolder(node)) {
            this._moveDLFolder(node, target);
          } else {
            var isShortcut = node.get(NODE_ATTR_SHORTCUT);
            if (!isShortcut) {
              this._moveDLFileEntry(node, target);
            } else {
              this._moveDLFileShortcut(node, target);
            }
          }
        },

        _moveJournalContentNode: function (node, target) {
          if (this._isFolder(node)) {
            this._moveJournalFolder(node, target);
          } else {
            this._moveJournalArticle(node, target);
          }
        },

        _moveDLFolder: function (folder, target) {
          var self = this;

          // if there's an async queue set
          if (self.q) {
            // pause it, until the move service is done
            self.q.pause();
          }

          Liferay.Service(
            "/dlapp/move-folder",
            {
              repositoryId: this.repository,
              folderId: folder.get(NODE_ATTR_ID),
              parentFolderId: target.get(NODE_ATTR_ID),
              serviceContext: JSON.stringify({
                scopeGroupId: this.repository,
              }),
            },
            function (file) {
              self._moveServiceHandler.apply(self, [folder, target]);
            }
          );
        },

        _moveDLFileEntry: function (entry, target) {
          var self = this;

          // if there's an async queue set
          if (self.q) {
            // pause it, until the move service is done
            self.q.pause();
          }

          Liferay.Service(
            "/dlapp/move-file-entry",
            {
              repositoryId: this.repository,
              fileEntryId: entry.get(NODE_ATTR_ID),
              newFolderId: target.get(NODE_ATTR_ID),
              serviceContext: JSON.stringify({
                scopeGroupId: this.repository,
              }),
            },
            function (file) {
              self._moveServiceHandler.apply(self, [entry, target]);
            }
          );
        },

        _moveDLFileShortcut: function (entry, target) {
          var self = this;

          if (self.q) {
            self.q.pause();
          }
          Liferay.Service(
            "/dlapp/update-file-shortcut",
            {
              fileShortcutId: entry.get(NODE_ATTR_ID),
              folderId: target.get(NODE_ATTR_ID),
              toFileEntryId: entry.get(NODE_ATTR_ENTRY_ID),
              serviceContext: JSON.stringify({
                scopeGroupId: this.repository,
              }),
            },
            function (file) {
              self._moveServiceHandler.apply(self, [entry, target]);
            }
          );
        },

        _moveJournalFolder: function (folder, target) {
          var self = this;

          if (self.q) {
            self.q.pause();
          }

          Liferay.Service(
            "/journalfolder/move-folder",
            {
              folderId: folder.get(NODE_ATTR_ID),
              parentFolderId: target.get(NODE_ATTR_ID),
              serviceContext: JSON.stringify({
                scopeGroupId: this.scopeGroupId,
              }),
            },
            function (file) {
              self._moveServiceHandler.apply(self, [folder, target]);
            }
          );
        },

        _moveJournalArticle: function (entry, target) {
          var self = this;

          if (self.q) {
            self.q.pause();
          }

          Liferay.Service(
            "/journalarticle/move-article",
            {
              groupId: this.scopeGroupId,
              articleId: entry.get(NODE_ATTR_ID),
              newFolderId: target.get(NODE_ATTR_ID),
            },
            function (file) {
              self._moveServiceHandler.apply(self, [entry, target]);
            }
          );
        },

        // gets called after moving an element using liferay services.
        _moveServiceHandler: function (entry, target) {
          // if multiple elements are being moved
          if (this.checkedArray && this.checkedArray.length > 1) {
            // remove it from it's old folder
            this.contentRoot.removeChild(entry);

            // make sure the entry is not already added to the target, to avoid duplication
            var match = target.getChildren().some(function (child) {
              return (
                child.get(NODE_ATTR_ENTRY_ID) === entry.get(NODE_ATTR_ENTRY_ID)
              );
            });

            // only add the node if it ifs not already there
            if (!match) {
              // add it to its new target
              target.appendChild(entry);
            }

            // move service is done, resume the async queue
            if (this.q) {
              this.q.run();
            }
          }
        },

        _mouseOverHandler: function (event) {
          event.stopPropagation();
          window.setTimeout(() => this.contentTree.get(TOOLTIP_HELPER_PROPERTY).hide(), 50);
          var treeNode = this.contentTree.getNodeById(
            event.currentTarget.get(NODE_ATTR_ID)
          );

          this._showPreview(treeNode);
        },

        _goToFileEntryViewPage: function (event) {
          event.stopPropagation();
          var treeNode = this.contentTree.getNodeById(
            event.currentTarget.get(NODE_ATTR_ID)
          );
          var viewURL = Liferay.PortletURL.createURL(this.viewPageBaseURL);
          if (this._isDLTarget()) {
            viewURL.setParameter(
              "fileEntryId",
              treeNode.get(NODE_ATTR_ENTRY_ID)
            );
          } else {
            viewURL.setParameter("articleId", treeNode.get(NODE_ATTR_ID));
            viewURL.setParameter(
              "folderId",
              treeNode.get(NODE_ATTR_PARENT_FOLDER)
            );
            viewURL.setParameter("groupId", this.scopeGroupId);
          }

          Liferay.Util.getOpener().location.href = viewURL.toString();
        },

        _showPreview: function (treeNode) {
          this.previewBoundingBox.empty();
          if (treeNode !== undefined && !this._isFolder(treeNode)) {
            var previewURL = treeNode.get(NODE_ATTR_PREVIEW_URL);
            var previewImgNode = treeNode.get(NODE_ATTR_PREVIEW_IMG_NODE);
            if (!previewImgNode && previewURL !== undefined) {
              previewImgNode = this._createPreview(treeNode);
            }
            this.previewBoundingBox.append(previewImgNode);
            if (treeNode.get(NODE_ATTR_SHORTCUT)) {
              this.previewBoundingBox.append(this.shortcutNode);
            }
          }
        },

        _clickHandler: function (event) {
          event.stopPropagation();

          var isHitArea = event.target.hasClass("tree-hitarea");
          var isCheckbox = event.target.hasClass(
            "tree-node-checkbox-container"
          );
          var isItemName = event.target.hasClass("tree-label");

          if (isHitArea) {
            this._clickHitArea(event);
          }

          //If click is over label it change the check status.
          // But it doesn't happen if it is the hit area.
          if (isCheckbox) {
            this._clickCheckBox(event);
          }

          if (isItemName) {
            var treeNode = this.contentTree.getNodeById(
              event.currentTarget.get(NODE_ATTR_ID)
            );
            if (!this._isFolder(treeNode)) {
              this._goToFileEntryViewPage(event);
            } else {
              this._clickCheckBox(event);
            }
          }

          this.contentTree.get(TOOLTIP_HELPER_PROPERTY).hide();
        },

        _createPreview: function (treeNode) {
          var previewImgId =
            this.ns + NODE_ATTR_PREVIEW_IMG_PREF + treeNode.get(NODE_ATTR_ID);
          var previewURL = treeNode.get(NODE_ATTR_PREVIEW_URL);
          var previewNode = A.Lang.sub(TPL_PREVIEW_NODE, {
            imgId: previewImgId,
            previewFileURL: previewURL,
          });

          treeNode.set(NODE_ATTR_PREVIEW_IMG_NODE, previewNode);
          return previewNode;
        },

        _clickCheckBox: function (event) {
          var node = event.currentTarget;
          var selectedNodeId = node.attr(NODE_ATTR_ID);
          var treeNode = node.getData(TREE_NODE);

          // update the checked elements array
          this._toggleCheckedArray(selectedNodeId);

          // trigger the event to simulate the click on the checkbox (toggle toolbar additional options).
          this._toggleCheckBox(selectedNodeId);

          // if the clicked checkbox is a folder
          if (this._isFolder(treeNode)) {
            // toggle its children
            this._toggleChildren(treeNode.getChildren());
          }
          // finally toggle the parent according the state of the given node
          this._toggleParent(treeNode);
        },

        _toggleParent: function (treeNode) {
          // get the parent node
          var parentNode = treeNode.get(PARENT_NODE);
          // when the entry is unchecked, all its parents must be unchecked
          if (
            typeof treeNode.isChecked === "function" &&
            !treeNode.isChecked()
          ) {
            // since the entry is unchecked, verify that the parent node is checked
            if (
              typeof parentNode.isChecked === "function" &&
              parentNode.isChecked()
            ) {
              // parent node is checked, uncheck it
              var parentNodeId = parentNode.get(NODE_ATTR_ID);
              parentNode.uncheck();
              this._toggleCheckBox(parentNodeId);
              this._toggleCheckedArray(parentNodeId);
              // repeat with all parents
              this._toggleParent(parentNode);
            }
          }
        },

        _toggleChildren: function (children) {
          var self = this;
          if (children) {
            children.forEach(function (child) {
              var nodeChild = child.get(BOUNDING_BOX);
              var nodeChildId = nodeChild.get(NODE_ATTR_ID);
              var isParentChecked = child.get(PARENT_NODE).isChecked();

              // ui toggle checkbox depending on parent status
              if (isParentChecked) {
                child.check();
              } else {
                child.uncheck();
              }

              // add or remove the element of the array, depending on the status of its parent
              self._setElementCheckedArray(nodeChildId, isParentChecked);

              // checkbox state toggle
              self._toggleCheckBox(nodeChildId, isParentChecked);

              // recursively toggle children
              var childArr = child.getChildren();
              if (childArr.length && childArr.length > 0) {
                self._toggleChildren(childArr);
              }
            });
          }
        },

        _toggleCheckBox: function (nodeId, isParentChecked) {
          var relatedCheckbox = this.hiddenFieldsBox.one(
            "[type=checkbox][value=" + nodeId + "]"
          );
          if (relatedCheckbox !== null) {
            // already checked
            if (relatedCheckbox.attr("checked")) {
              if (!isParentChecked) {
                relatedCheckbox.simulate("click");
              }
            } else {
              relatedCheckbox.simulate("click");
            }
          }
        },

        _toggleCheckedArray: function (selectedNodeId) {
          // search for the id in the array
          var index = this.checkedArray.indexOf(selectedNodeId);

          // add the nodeId to the checked array
          if (index > -1) {
            this.checkedArray.splice(index, 1);
          } else {
            this.checkedArray.push(selectedNodeId);
          }
        },

        _resetCheckedArray: function () {
          var self = this;
          var tree = A.one("#" + this.ns + ENTRIES_SEARCH_CONTAINER);
          this.checkedArray.forEach(function (id) {
            var childDOM = tree.one("#" + id);
            childDOM.getData(TREE_NODE).uncheck();
            self._toggleCheckBox(id);
          });
          this.checkedArray.splice(0, this.checkedArray.length);
        },

        _setElementCheckedArray: function (id, check) {
          var index = this.checkedArray.indexOf(id);
          // if the item was checked and it's not in the array, add it
          if (check) {
            if (index === -1) {
              this.checkedArray.push(id);
            }
          } else {
            // if the item was unchecked and it is in the array, remove it
            if (index > -1) {
              this.checkedArray.splice(index, 1);
            }
          }
        },

        _clickHitArea: function (event) {
          var treeNode = this.contentTree.getNodeById(
            event.currentTarget.attr(NODE_ATTR_ID)
          );
          if (treeNode) {
            if (!this._isFullLoaded(treeNode)) {
              this._getChildren(treeNode, this);
            }
          }
        },

        _selectAllHiddenCheckbox: function (event) {
          var checked = event.target.attr("checked");
          this.contentTree
            .get(BOUNDING_BOX)
            .all(NODE_CHECKBOX_SELECTOR)
            .each(function (node) {
              var nodeChecked = node.one("[type=checkbox]").attr("checked");
              if (nodeChecked !== checked) {
                node.fire("click");
              }
            });
        },

        _addContentNode: function (newNodeConfig, parentNode, isFolder) {
          var nodeType = "";
          var label = newNodeConfig.label;
          var nodeId = newNodeConfig.id;

          if (
            parentNode === undefined &&
            newNodeConfig.parentFolderId !== undefined
          ) {
            parentNode = this.contentTree.getNodeById(
              newNodeConfig.parentFolderId
            );
          }

          if (newNodeConfig.showCheckbox) {
            nodeType = NODE_TYPE_CHECKBOX;
          }

          if (parentNode === undefined) {
            parentNode = this.contentRoot;
          }

          var expanded =
            newNodeConfig.expanded !== undefined
              ? newNodeConfig.expanded
              : false;

          if (newNodeConfig.shortcut) {
            label = Liferay.Language.get(SHORTCUT_LABEL) + label;
            nodeId = newNodeConfig.rowCheckerId;
          }

          var newNode = this.contentRoot.createNode({
            id: nodeId,
            label: label,
            draggable: true,
            alwaysShowHitArea: true,
            leaf: !isFolder,
            type: nodeType,
            expanded: expanded,
          });
          newNode.set(NODE_ATTR_PARENT_FOLDER, newNodeConfig.parentFolderId);
          newNode.set(NODE_ATTR_IS_FOLDER, isFolder);
          newNode.set(NODE_ATTR_FULL_LOADED, newNodeConfig.fullLoaded);
          newNode.set(NODE_ATTR_SHORTCUT, newNodeConfig.shortcut);
          newNode.set(NODE_ATTR_ENTRY_ID, newNodeConfig.id);

          if (newNodeConfig.previewURL !== undefined) {
            newNode.set(NODE_ATTR_PREVIEW_URL, newNodeConfig.previewURL);
          }

          // for some reason, sometimes the node is duplicated after being dragged (IE and Firefox, rare in Chrome).
          // this forces a validation to check if the node is already added to the destination node
          var match = parentNode.getChildren().some(function (child) {
            return (
              child.get(NODE_ATTR_ENTRY_ID) === newNode.get(NODE_ATTR_ENTRY_ID)
            );
          });

          // only add the node if it is not already there
          if (!match) {
            parentNode.appendChild(newNode);
          }

          if (nodeType === NODE_TYPE_CHECKBOX) {
            // add checkbox
            this._addProcessCheckbox(newNodeConfig);
          }

          boundingBox = this.contentTree.get(BOUNDING_BOX);
          boundingBox.detach("click");
          boundingBox.detach("mouseover");
          boundingBox.delegate(
            "click",
            A.bind(this._clickHandler, this),
            NODE_SELECTOR
          );
          boundingBox.delegate(
            "mouseover",
            A.bind(this._mouseOverHandler, this),
            NODE_SELECTOR
          );
          this.contentTree.bindUI();
        },

        _addProcessCheckbox: function (newNodeConfig) {
          this.hiddenFieldsBox.append(
            this.compiledItemSelectorTemplate(newNodeConfig)
          );
        },

        _getChildren: function (treeNode, instance) {
          if (this._isDLTarget()) {
            this._getDLChildren(treeNode, instance);
          } else {
            this._getWCChildren(treeNode, instance);
          }
        },

        _getDLChildren: function (treeNode, instance) {
          var self = this;
          // Get folders children of this folder
          Liferay.Service(
            "/rivetlogic_treeview.enhanceddlapp/get-folders-and-file-entries-and-file-shortcuts",
            {
              repositoryId: instance.repository,
              folderId: treeNode.get(NODE_ATTR_ID),
              status: WORKFLOW_STATUS_ANY,
              includeMountFolders: true,
              start: QUERY_ALL,
              end: QUERY_ALL,
            },
            function (entries) {
              A.each(entries, function (item, index, collection) {
                var enableCheckbox =
                  item.deletePermission || item.updatePermission;
                //if it is a file entry
                if (item.fileEntryId !== undefined) {
                  var documentImageURL = instance._getDocumentImageURL(item);
                  instance.addContentEntry(
                    {
                      id: item.fileEntryId.toString(),
                      label: item.title,
                      shortcut: item.shortcut,
                      showCheckbox: enableCheckbox,
                      rowCheckerId: item.rowCheckerId,
                      rowCheckerName: `rowIds${item.rowCheckerName}`,
                      expanded: false,
                      fullLoaded: true,
                      previewURL: documentImageURL,
                    },
                    treeNode
                  );
                }
                //If it is a folder
                else {
                  instance.addContentFolder(
                    {
                      id: item.folderId.toString(),
                      label: item.name,
                      showCheckbox: enableCheckbox,
                      rowCheckerId: item.rowCheckerId,
                      rowCheckerName: `rowIds${item.rowCheckerName}`,
                      expanded: false,
                      fullLoaded: false,
                    },
                    treeNode
                  );
                }
              });

              treeNode.set(NODE_ATTR_FULL_LOADED, true);
              treeNode.expand();
              self.contentTree.get(TOOLTIP_HELPER_PROPERTY).hide();
            }
          );
        },

        _getWCChildren: function (treeNode, instance) {
          var self = this;
          // Get folders children of this folder
          Liferay.Service(
            "/content-tree-view-hook.enhancedjournalapp/get-folders-and-articles",
            {
              groupId: instance.scopeGroupId,
              folderId: treeNode.get(NODE_ATTR_ID),
              start: QUERY_ALL,
              end: QUERY_ALL,
            },
            function (entries) {
              A.each(entries, function (item, index, collection) {
                var enableCheckbox =
                  item.deletePermission || item.updatePermission;
                //if it is an article
                if (item.articleId !== undefined) {
                  enableCheckbox = enableCheckbox || item.expirePermission;
                  var articleImageURL = instance._getArticleImageURL(item);
                  instance.addContentEntry(
                    {
                      id: item.articleId.toString(),
                      label: item.title,
                      showCheckbox: enableCheckbox,
                      rowCheckerId: item.rowCheckerId,
                      rowCheckerName: item.rowCheckerName,
                      expanded: false,
                      fullLoaded: true,
                      previewURL: articleImageURL,
                    },
                    treeNode
                  );
                }
                //If it is a folder
                else {
                  instance.addContentFolder(
                    {
                      id: item.folderId.toString(),
                      label: item.name,
                      showCheckbox: enableCheckbox,
                      rowCheckerId: item.rowCheckerId,
                      rowCheckerName: item.rowCheckerName,
                      expanded: false,
                      fullLoaded: false,
                    },
                    treeNode
                  );
                }
              });

              treeNode.set(NODE_ATTR_FULL_LOADED, true);
              treeNode.expand();
              self.contentTree.get(TOOLTIP_HELPER_PROPERTY).hide();
            }
          );
        },

        _getArticleImageURL: function (item) {
          var articleImageURL = item.articleImageURL;
          if (articleImageURL === null || articleImageURL === undefined) {
            articleImageURL = this.defaultArticleImage;
          } else if (
            A.Lang.String.startsWith(articleImageURL, "/journal/article")
          ) {
            articleImageURL = themeDisplay.getPathImage() + articleImageURL;
          }
          return articleImageURL;
        },

        _getDocumentImageURL: function (item) {
          var documentImageURL = item.previewFileURL;
          if (documentImageURL === null || documentImageURL === undefined) {
            documentImageURL =
              this.defaultDocumentImagePath + item.extension + ".png";
          }
          return documentImageURL;
        },

        _isFolder: function (treeNode) {
          result = false;
          if (treeNode) {
            result = treeNode.get(NODE_ATTR_IS_FOLDER);
          }
          return result;
        },

        _isFullLoaded: function (treeNode) {
          result = false;
          if (treeNode) {
            result = treeNode.get(NODE_ATTR_FULL_LOADED);
          }
          return result;
        },

        _isChecked: function (treeNode) {
          var result = false;
          if (treeNode && treeNode.isChecked) {
            result = treeNode.isChecked();
          }
          return result;
        },
      },
      {
        ATTRS: {
          namespace: {
            value: null,
          },
          treeTarget: {
            value: null,
          },
          repositoryId: {
            value: null,
          },
          scopeGroupId: {
            value: null,
          },
          rootFolderId: {
            value: null,
          },
          rootFolderLabel: {
            value: null,
          },
          checkAllId: {
            value: null,
          },
          viewPageBaseURL: {
            value: null,
          },
          shortcutImageURL: {
            value: null,
          },
          defaultArticleImage: {
            value: null,
          },
          defaultDocumentImagePath: {
            value: null,
          },
          searchContainer: {
            value: null,
          },
        },
      }
    );
  },
  "1.0.0",
  {
    requires: [
      "aui-tree-view",
      "json",
      "liferay-portlet-url",
      "handlebars",
      "liferay-preview",
      "aui-loading-mask-deprecated",
      "async-queue",
    ],
  }
);
