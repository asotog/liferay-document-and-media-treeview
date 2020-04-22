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

import com.liferay.portal.kernel.repository.model.Folder;
import com.liferay.portal.kernel.util.StringPool;

import java.io.Serializable;

/**
 * POJO for DL Folder, augmented in order to add permissions
 * @author rivetlogic
 *
 */
public class DLFolder implements Serializable{

    private static final long serialVersionUID = 1L;
    private long folderId;
    private String name = StringPool.BLANK;
    private long parentFolderId;
    private long repositoryId;
    private boolean deletePermission;
    private boolean updatePermission;
    private String rowCheckerId = StringPool.BLANK;
    private String rowCheckerName = StringPool.BLANK;
    
    public DLFolder(Folder folder){
        this.setFolderId(folder.getFolderId());
        this.setName(folder.getName());
        this.setParentFolderId(folder.getParentFolderId());
        this.setRepositoryId(folder.getRepositoryId());
        this.deletePermission = false;
        this.updatePermission = false;
        this.rowCheckerId = String.valueOf(folder.getFolderId());
        this.rowCheckerName = Folder.class.getSimpleName();
    }
    
    public long getFolderId() {
        return folderId;
    }
    
    public void setFolderId(long folderId) {
        this.folderId = folderId;
    }
    
    public String getName() {
        return name;
    }
    
    public void setName(String name) {
        this.name = name;
    }
    
    public long getParentFolderId() {
        return parentFolderId;
    }
    
    public void setParentFolderId(long parentFolderId) {
        this.parentFolderId = parentFolderId;
    }
    
    public long getRepositoryId() {
        return repositoryId;
    }
    
    public void setRepositoryId(long repositoryId) {
        this.repositoryId = repositoryId;
    }
    
    public boolean isDeletePermission() {
        return deletePermission;
    }
    
    public void setDeletePermission(boolean hasDeletePermission) {
        this.deletePermission = hasDeletePermission;
    }
    
    public boolean isUpdatePermission() {
        return updatePermission;
    }
    
    public void setUpdatePermission(boolean hasUpdatePermission) {
        this.updatePermission = hasUpdatePermission;
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
