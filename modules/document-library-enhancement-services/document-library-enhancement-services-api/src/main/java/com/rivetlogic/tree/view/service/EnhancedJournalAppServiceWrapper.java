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
 * Provides a wrapper for {@link EnhancedJournalAppService}.
 *
 * @author rivetlogic
 * @see EnhancedJournalAppService
 * @generated
 */
public class EnhancedJournalAppServiceWrapper
	implements EnhancedJournalAppService,
			   ServiceWrapper<EnhancedJournalAppService> {

	public EnhancedJournalAppServiceWrapper(
		EnhancedJournalAppService enhancedJournalAppService) {

		_enhancedJournalAppService = enhancedJournalAppService;
	}

	@Override
	public java.util.List<Object> getFoldersAndArticles(
			long groupId, long folderId, int start, int end)
		throws com.liferay.portal.kernel.exception.SystemException {

		return _enhancedJournalAppService.getFoldersAndArticles(
			groupId, folderId, start, end);
	}

	/**
	 * Returns the OSGi service identifier.
	 *
	 * @return the OSGi service identifier
	 */
	@Override
	public String getOSGiServiceIdentifier() {
		return _enhancedJournalAppService.getOSGiServiceIdentifier();
	}

	@Override
	public EnhancedJournalAppService getWrappedService() {
		return _enhancedJournalAppService;
	}

	@Override
	public void setWrappedService(
		EnhancedJournalAppService enhancedJournalAppService) {

		_enhancedJournalAppService = enhancedJournalAppService;
	}

	private EnhancedJournalAppService _enhancedJournalAppService;

}