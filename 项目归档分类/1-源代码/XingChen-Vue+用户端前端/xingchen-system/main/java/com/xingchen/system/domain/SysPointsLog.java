package com.xingchen.system.domain;

import com.xingchen.common.annotation.Excel;
import com.xingchen.common.core.domain.BaseEntity;

/**
 * 积分流水对象 sys_points_log
 * 
 * @author xingchen
 */
public class SysPointsLog extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    /** 流水唯一标识 */
    private Long id;

    /** 发生积分变动的员工ID */
    @Excel(name = "员工ID")
    private Long userId;

    /** 操作类型：1=收入（加分），2=支出（扣分） */
    @Excel(name = "操作类型", readConverterExp = "1=收入,2=支出")
    private Integer operateType;

    /** 参与场景：1=每日打卡，2=连续打卡奖励，3=兑换商品消耗，4=HR手动退还积分 */
    @Excel(name = "参与场景", readConverterExp = "1=每日打卡,2=连续打卡奖励,3=兑换商品消耗,4=HR手动退还积分")
    private Integer sourceType;

    /** 本次波动的分值（绝对值） */
    @Excel(name = "波动分值")
    private Integer points;

    /** 业务关联ID（如打卡记录ID、兑换订单ID） */
    @Excel(name = "业务关联ID")
    private Long referenceId;

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
    public void setOperateType(Integer operateType) 
    {
        this.operateType = operateType;
    }

    public Integer getOperateType() 
    {
        return operateType;
    }
    public void setSourceType(Integer sourceType) 
    {
        this.sourceType = sourceType;
    }

    public Integer getSourceType() 
    {
        return sourceType;
    }
    public void setPoints(Integer points) 
    {
        this.points = points;
    }

    public Integer getPoints() 
    {
        return points;
    }
    public void setReferenceId(Long referenceId) 
    {
        this.referenceId = referenceId;
    }

    public Long getReferenceId() 
    {
        return referenceId;
    }

    @Override
    public String toString() {
        return "SysPointsLog{" +
            "id=" + id +
            ", userId=" + userId +
            ", operateType=" + operateType +
            ", sourceType=" + sourceType +
            ", points=" + points +
            ", referenceId=" + referenceId +
            "} " + super.toString();
    }
}
