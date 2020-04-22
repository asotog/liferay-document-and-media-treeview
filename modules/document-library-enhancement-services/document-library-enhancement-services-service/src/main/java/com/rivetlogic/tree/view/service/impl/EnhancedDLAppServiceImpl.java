/**
 * Copyright (c) 2000-present Liferay, Inc. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation; either version 2.1 of the License, or (at your option)
 * any later version.
 *
 * This library is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
 * details.
 */

package com.rivetlogic.tree.view.service.impl;

import com.liferay.portal.aop.AopService;

import com.rivetlogic.tree.view.service.base.EnhancedDLAppServiceBaseImpl;

import org.osgi.service.component.annotations.Component;

import com.liferay.portal.kernel.exception.PortalException;
import com.liferay.portal.kernel.exception.SystemException;
import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.repository.model.FileEntry;
import com.liferay.portal.kernel.repository.model.FileVersion;
import com.liferay.portal.kernel.repository.model.Folder;
import com.liferay.portal.kernel.util.Validator;

import com.liferay.portal.kernel.security.permission.ActionKeys;
import com.liferay.portal.kernel.theme.ThemeDisplay;
import com.liferay.document.library.kernel.model.DLFileShortcut;
import com.liferay.document.library.kernel.service.DLAppServiceUtil;
import com.liferay.document.library.kernel.util.DLUtil;
import com.liferay.document.library.kernel.util.ImageProcessorUtil;
import com.liferay.document.library.kernel.util.PDFProcessorUtil;
import com.liferay.document.library.kernel.util.VideoProcessorUtil;
import com.rivetlogic.tree.view.model.DLFileEntry;
import com.rivetlogic.tree.view.model.DLFolder;
import java.util.ArrayList;
import java.util.List;
/**
 * The implementation of the enhanced dl app remote service.
 *
 * <p>
 * All custom service methods should be put in this class. Whenever methods are added, rerun ServiceBuilder to copy their definitions into the <code>com.rivetlogic.tree.view.service.EnhancedDLAppService</code> interface.
 *
 * <p>
 * This is a remote service. Methods of this service are expected to have security checks based on the propagated JAAS credentials because this service can be accessed remotely.
 * </p>
 *
 * @author rivetlogic
 * @see EnhancedDLAppServiceBaseImpl
 */
@Component(
	property = {
		"json.web.service.context.name=rivetlogic_treeview",
		"json.web.service.context.path=EnhancedDLApp"
	},
	service = AopService.class
)
public class EnhancedDLAppServiceImpl extends EnhancedDLAppServiceBaseImpl {

	/*
	 * NOTE FOR DEVELOPERS:
	 *
	 * Never reference this class directly. Always use <code>com.rivetlogic.tree.view.service.EnhancedDLAppServiceUtil</code> to access the enhanced dl app remote service.
	 */

	private static final String IMAGE_THUMBNAIL_QUERY_STRING = "&imageThumbnail=1";
    private static final String DOCUMENT_THUMBNAIL_QUERY_STRING = "&documentThumbnail=1";
    private static final String VIDEO_THUMBNAIL_QUERY_STRING = "&videoThumbnail=1";
	private static final Log log = LogFactoryUtil.getLog(EnhancedDLAppServiceImpl.class);
	
	public List<Object> getFoldersAndFileEntriesAndFileShortcuts(long repositoryId, long folderId, int status,
		boolean includeMountFolders, int start, int end) throws PortalException, SystemException {
			List<Object> items = DLAppServiceUtil.getFoldersAndFileEntriesAndFileShortcuts(repositoryId, folderId, status,
			includeMountFolders, start, end);

		List<Object> results = new ArrayList<Object>();

		for (Object o : items) {

			if (o instanceof Folder) {
				Folder folder = (Folder) o;
				DLFolder dlFolder = new DLFolder(folder);
				dlFolder.setDeletePermission(folder.containsPermission(getPermissionChecker(), ActionKeys.DELETE));
				dlFolder.setUpdatePermission(folder.containsPermission(getPermissionChecker(), ActionKeys.UPDATE));
				results.add(dlFolder);
			}
			if (o instanceof FileEntry) {
				FileEntry fileEntry = (FileEntry) o;
				DLFileEntry dlFileEntry = new DLFileEntry(fileEntry);
				dlFileEntry
						.setDeletePermission(fileEntry.containsPermission(getPermissionChecker(), ActionKeys.DELETE));
				dlFileEntry
						.setUpdatePermission(fileEntry.containsPermission(getPermissionChecker(), ActionKeys.UPDATE));
				dlFileEntry.setPreviewFileURL(getThumbnailURL(fileEntry, null, dlFileEntry));
				results.add(dlFileEntry);
			}
			if (o instanceof DLFileShortcut) {
				DLFileShortcut dLFileShortcut = (DLFileShortcut) o;
				FileEntry fileEntry = DLAppServiceUtil.getFileEntry(dLFileShortcut.getToFileEntryId());
				DLFileEntry dlFileEntry = new DLFileEntry(fileEntry);
				dlFileEntry
						.setDeletePermission(fileEntry.containsPermission(getPermissionChecker(), ActionKeys.DELETE));
				dlFileEntry
						.setUpdatePermission(fileEntry.containsPermission(getPermissionChecker(), ActionKeys.UPDATE));
				dlFileEntry.setShortcut(true);
				dlFileEntry.setRowCheckerName(DLFileShortcut.class.getSimpleName());
				dlFileEntry.setRowCheckerId(String.valueOf(dLFileShortcut.getFileShortcutId()));
				dlFileEntry.setPreviewFileURL(getThumbnailURL(fileEntry, dLFileShortcut, dlFileEntry));
				results.add(dlFileEntry);
			}
		}
		return results;
	}

	private String getThumbnailURL(final FileEntry fileEntry, final DLFileShortcut fileShortcut,
		final DLFileEntry dlFileEntry) {
		ThemeDisplay themeDisplay = null;
        String thumbnailSrc = null;
        FileVersion latestFileVersion;

        try {
            latestFileVersion = fileEntry.getLatestFileVersion();
            String thumbnailQueryString = null;

            if (PropsValues.DL_FILE_ENTRY_THUMBNAIL_ENABLED) {
                if (ImageProcessorUtil.hasImages(latestFileVersion)) {
                    thumbnailQueryString = IMAGE_THUMBNAIL_QUERY_STRING;
                } else if (PDFProcessorUtil.hasImages(latestFileVersion)) {
                    thumbnailQueryString = DOCUMENT_THUMBNAIL_QUERY_STRING;
                } else if (VideoProcessorUtil.hasVideo(latestFileVersion)) {
                    thumbnailQueryString = VIDEO_THUMBNAIL_QUERY_STRING;
                }
            }

            if (Validator.isNotNull(thumbnailQueryString)) {
                thumbnailSrc = DLUtil.getPreviewURL(fileEntry, latestFileVersion, themeDisplay, thumbnailQueryString,
                        true, true);
            }

        } catch (PortalException e) {
            log.error(e);
        } catch (SystemException e) {
            log.error(e);
        }

        return thumbnailSrc;
	}
}