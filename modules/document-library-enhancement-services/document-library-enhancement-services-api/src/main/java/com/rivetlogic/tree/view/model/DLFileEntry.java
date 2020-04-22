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

package com.rivetlogic.tree.view.model;

import com.liferay.portal.kernel.repository.model.FileEntry;
import com.liferay.portal.kernel.util.StringPool;
import com.liferay.document.library.kernel.util.DLUtil;

import java.io.Serializable;

/**
 * POJO for DL FileEntry, augmented in order to add permissions
 * 
 * @author rivetlogic
 * 
 */
public class DLFileEntry implements Serializable {

    private static final long serialVersionUID = 1L;
    private long fileEntryId;
    private String title = StringPool.BLANK;
    private String description = StringPool.BLANK;
    private String version = StringPool.BLANK;
    private String extension = StringPool.BLANK;
    private long folderId;
    private long repositoryId;
    private boolean shortcut = false;
    private boolean deletePermission;
    private boolean updatePermission;
    private String previewFileURL;
    private String rowCheckerId = StringPool.BLANK;
    private String rowCheckerName = StringPool.BLANK;

    public DLFileEntry(FileEntry fileEntry) {
        this.fileEntryId = fileEntry.getFileEntryId();
        this.title = fileEntry.getTitle();
        this.description = fileEntry.getDescription();
        this.version = fileEntry.getVersion();
        this.extension = DLUtil.getGenericName(fileEntry.getExtension());
        this.folderId = fileEntry.getFileEntryId();
        this.repositoryId = fileEntry.getRepositoryId();
        this.deletePermission = false;
        this.updatePermission = false;
        this.rowCheckerId = String.valueOf(fileEntry.getFileEntryId());
        this.rowCheckerName = FileEntry.class.getSimpleName();
    }

    public long getFileEntryId() {
        return fileEntryId;
    }

    public void setFileEntryId(long fileEntryId) {
        this.fileEntryId = fileEntryId;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getVersion() {
        return version;
    }

    public void setVersion(String version) {
        this.version = version;
    }

    public String getExtension() {
        return extension;
    }

    public void setExtension(String extension) {
        this.extension = extension;
    }

    public long getFolderId() {
        return folderId;
    }

    public void setFolderId(long folderId) {
        this.folderId = folderId;
    }

    public long getRepositoryId() {
        return repositoryId;
    }

    public void setRepositoryId(long repositoryId) {
        this.repositoryId = repositoryId;
    }

    public boolean isShortcut() {
        return shortcut;
    }

    public void setShortcut(boolean shortcut) {
        this.shortcut = shortcut;
    }

    public boolean isDeletePermission() {
        return deletePermission;
    }

    public void setDeletePermission(boolean deletePermission) {
        this.deletePermission = deletePermission;
    }

    public boolean isUpdatePermission() {
        return updatePermission;
    }

    public void setUpdatePermission(boolean updatePermission) {
        this.updatePermission = updatePermission;
    }

    public String getPreviewFileURL() {
        return previewFileURL;
    }

    public void setPreviewFileURL(String previewFileURL) {
        this.previewFileURL = previewFileURL;
    }

    public String getRowCheckerId() {
        return rowCheckerId;
    }

    public void setRowCheckerId(String rowCheckerId) {
        this.rowCheckerId = rowCheckerId;
    }

    public String getRowCheckerName() {
        return rowCheckerName;
    }

    public void setRowCheckerName(String rowCheckerName) {
        this.rowCheckerName = rowCheckerName;
    }
}
