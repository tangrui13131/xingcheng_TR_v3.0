package com.xingchen.system.service;

import java.util.List;
import com.xingchen.system.domain.SysRedemption;

/**
 * 积分兑换订单Service接口
 * 
 * @author xingchen
 */
public interface ISysRedemptionService 
{
    /**
     * 查询兑换订单列表
     * 
     * @param redemption 兑换订单
     * @return 兑换订单集合
     */
    public List<SysRedemption> selectRedemptionList(SysRedemption redemption);

    /**
     * 根据ID查询兑换订单
     * 
     * @param id 兑换订单主键
     * @return 兑换订单
     */
    public SysRedemption selectRedemptionById(Long id);

    /**
     * 用户提交兑换申请
     * 
     * @param redemption 兑换订单
     * @return 结果
     */
    public int submitRedemption(SysRedemption redemption);

    /**
     * HR通过审核
     * 
     * @param id 兑换订单主键
     * @return 结果
     */
    public int approveRedemption(Long id);

    /**
     * HR驳回审核
     * 
     * @param id 兑换订单主键
     * @param reason 驳回原因
     * @return 结果
     */
    public int rejectRedemption(Long id, String reason);

    /**
     * 查询用户自己的兑换记录
     * 
     * @param userId 用户ID
     * @return 兑换订单集合
     */
    public List<SysRedemption> selectMyRedemptions(Long userId);
}
