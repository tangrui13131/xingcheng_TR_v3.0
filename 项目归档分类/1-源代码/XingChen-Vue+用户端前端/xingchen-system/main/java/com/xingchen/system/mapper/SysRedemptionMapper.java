package com.xingchen.system.mapper;

import java.util.List;
import com.xingchen.system.domain.SysRedemption;

/**
 * 积分兑换订单Mapper接口
 * 
 * @author xingchen
 */
public interface SysRedemptionMapper 
{
    /**
     * 查询兑换订单列表
     * 
     * @param sysRedemption 兑换订单
     * @return 兑换订单集合
     */
    public List<SysRedemption> selectRedemptionList(SysRedemption sysRedemption);

    /**
     * 查询兑换订单
     * 
     * @param id 兑换订单主键
     * @return 兑换订单
     */
    public SysRedemption selectRedemptionById(Long id);

    /**
     * 新增兑换订单
     * 
     * @param sysRedemption 兑换订单
     * @return 结果
     */
    public int insertRedemption(SysRedemption sysRedemption);

    /**
     * 修改兑换订单
     * 
     * @param sysRedemption 兑换订单
     * @return 结果
     */
    public int updateRedemption(SysRedemption sysRedemption);

    /**
     * 按用户ID查询兑换订单列表
     * 
     * @param userId 用户ID
     * @return 兑换订单集合
     */
    public List<SysRedemption> selectRedemptionsByUserId(Long userId);
}
