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

package com.rivetlogic.tree.view.service;

import com.liferay.portal.kernel.service.ServiceWrapper;

/**
 * Provides a wrapper for {@link EnhancedDLAppService}.
 *
 * @author rivetlogic
 * @see EnhancedDLAppService
 * @generated
 */
public class EnhancedDLAppServiceWrapper
	implements EnhancedDLAppService, ServiceWrapper<EnhancedDLAppService> {

	public EnhancedDLAppServiceWrapper(
		EnhancedDLAppService enhancedDLAppService) {

		_enhancedDLAppService = enhancedDLAppService;
	}

	@Override
	public java.util.List<Object> getFoldersAndFileEntriesAndFileShortcuts(
			long repositoryId, long folderId, int status,
			boolean includeMountFolders, int start, int end)
		throws com.liferay.portal.kernel.exception.PortalException,
			   com.liferay.portal.kernel.exception.SystemException {

		return _enhancedDLAppService.getFoldersAndFileEntriesAndFileShortcuts(
			repositoryId, folderId, status, includeMountFolders, start, end);
	}

	/**
	 * Returns the OSGi service identifier.
	 *
	 * @return the OSGi service identifier
	 */
	@Override
	public String getOSGiServiceIdentifier() {
		return _enhancedDLAppService.getOSGiServiceIdentifier();
	}

	@Override
	public EnhancedDLAppService getWrappedService() {
		return _enhancedDLAppService;
	}

	@Override
	public void setWrappedService(EnhancedDLAppService enhancedDLAppService) {
		_enhancedDLAppService = enhancedDLAppService;
	}

	private EnhancedDLAppService _enhancedDLAppService;

}