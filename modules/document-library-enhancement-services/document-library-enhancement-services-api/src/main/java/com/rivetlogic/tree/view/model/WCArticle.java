package com.rivetlogic.tree.view.model;

import com.liferay.portal.kernel.util.LocaleUtil;
import com.liferay.portal.kernel.util.StringPool;
import com.liferay.journal.model.JournalArticle;

import java.io.Serializable;

/**
 * POJO for Journal Article, augmented in order to add permissions
 * 
 * @author rivetlogic
 * 
 */
public class WCArticle implements Serializable {

    private static final long serialVersionUID = 1L;
    private String articleId = StringPool.BLANK;
    private String title = StringPool.BLANK;
    private double version;
    private long folderId;
    private long groupId;
    private boolean deletePermission;
    private boolean updatePermission;
    private boolean expirePermission;
    private String articleImageURL = StringPool.BLANK;
    private String rowCheckerId = StringPool.BLANK;
    private String rowCheckerName = StringPool.BLANK;

    public WCArticle(JournalArticle article) {
        this.articleId = article.getArticleId();
        this.version = article.getVersion();
        this.title = article.getTitle(LocaleUtil.getSiteDefault());
        this.folderId = article.getFolderId();
        this.groupId = article.getGroupId();
        this.deletePermission = false;
        this.updatePermission = false;
        this.rowCheckerId = article.getArticleId();
        this.rowCheckerName = JournalArticle.class.getSimpleName();
    }

    public String getArticleId() {
        return articleId;
    }

    public void setArticleId(String articleId) {
        this.articleId = articleId;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public double getVersion() {
        return version;
    }

    public void setVersion(double version) {
        this.version = version;
    }

    public long getFolderId() {
        return folderId;
    }

    public void setFolderId(long folderId) {
        this.folderId = folderId;
    }

    public long getGroupId() {
        return groupId;
    }

    public void setGroupId(long groupId) {
        this.groupId = groupId;
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

    public boolean isExpirePermission() {
        return expirePermission;
    }

    public void setExpirePermission(boolean expirePermission) {
        this.expirePermission = expirePermission;
    }

    public String getArticleImageURL() {
        return articleImageURL;
    }

    public void setArticleImageURL(String articleImageURL) {
        this.articleImageURL = articleImageURL;
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
