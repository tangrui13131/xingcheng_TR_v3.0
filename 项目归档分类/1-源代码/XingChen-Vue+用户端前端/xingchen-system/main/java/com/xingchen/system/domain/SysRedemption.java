package com.xingchen.system.domain;

import java.util.Date;
import com.fasterxml.jackson.annotation.JsonFormat;
import com.xingchen.common.annotation.Excel;
import com.xingchen.common.core.domain.BaseEntity;

/**
 * 积分兑换订单对象 sys_redemption
 * 
 * @author xingchen
 */
public class SysRedemption extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    /** 兑换订单ID */
    private Long id;

    /** 申请人ID */
    @Excel(name = "申请人ID")
    private Long userId;

    /** 商品名称 */
    @Excel(name = "商品名称")
    private String productName;

    /** 消耗积分 */
    @Excel(name = "消耗积分")
    private Integer pointsCost;

    /** 审核状态（0待审核 1已通过 2已驳回） */
    @Excel(name = "审核状态", readConverterExp = "0=待审核,1=已通过,2=已驳回")
    private String status;

    /** 申请时间 */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    @Excel(name = "申请时间", width = 30, dateFormat = "yyyy-MM-dd HH:mm:ss")
    private Date applyTime;

    /** 审核时间 */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    @Excel(name = "审核时间", width = 30, dateFormat = "yyyy-MM-dd HH:mm:ss")
    private Date auditTime;

    /** 审核人ID */
    @Excel(name = "审核人ID")
    private Long auditorId;

    /** 驳回原因 */
    @Excel(name = "驳回原因")
    private String rejectReason;

    /** 申请人用户名（关联查询） */
    @Excel(name = "申请人")
    private String userName;

    /** 申请人部门名（关联查询） */
    @Excel(name = "部门")
    private String deptName;

    public void setId(Long id)
    {
        this.id = id;
    }

    public Long getId()
    {
        return id;
    }
    public void setUserId(Long userId)
    {
        this.userId = userId;
    }

    public Long getUserId()
    {
        return userId;
    }
    public void setProductName(String productName)
    {
        this.productName = productName;
    }

    public String getProductName()
    {
        return productName;
    }
    public void setPointsCost(Integer pointsCost)
    {
        this.pointsCost = pointsCost;
    }

    public Integer getPointsCost()
    {
        return pointsCost;
    }
    public void setStatus(String status)
    {
        this.status = status;
    }

    public String getStatus()
    {
        return status;
    }
    public void setApplyTime(Date applyTime)
    {
        this.applyTime = applyTime;
    }

    public Date getApplyTime()
    {
        return applyTime;
    }
    public void setAuditTime(Date auditTime)
    {
        this.auditTime = auditTime;
    }

    public Date getAuditTime()
    {
        return auditTime;
    }
    public void setAuditorId(Long auditorId)
    {
        this.auditorId = auditorId;
    }

    public Long getAuditorId()
    {
        return auditorId;
    }
    public void setRejectReason(String rejectReason)
    {
        this.rejectReason = rejectReason;
    }

    public String getRejectReason()
    {
        return rejectReason;
    }
    public void setUserName(String userName)
    {
        this.userName = userName;
    }

    public String getUserName()
    {
        return userName;
    }
    public void setDeptName(String deptName)
    {
        this.deptName = deptName;
    }

    public String getDeptName()
    {
        return deptName;
    }

    @Override
    public String toString() {
        return "SysRedemption{" +
            "id=" + id +
            ", userId=" + userId +
            ", productName='" + productName + '\'' +
            ", pointsCost=" + pointsCost +
            ", status='" + status + '\'' +
            ", applyTime=" + applyTime +
            ", auditTime=" + auditTime +
            ", auditorId=" + auditorId +
            ", rejectReason='" + rejectReason + '\'' +
            ", userName='" + userName + '\'' +
            ", deptName='" + deptName + '\'' +
            "} " + super.toString();
    }
}
