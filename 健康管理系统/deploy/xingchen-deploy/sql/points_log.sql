-- ----------------------------
-- 1、积分流水表
-- ----------------------------
DROP TABLE IF EXISTS `sys_points_log`;
CREATE TABLE `sys_points_log` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '流水唯一标识',
  `user_id` bigint(20) NOT NULL COMMENT '发生积分变动的员工ID',
  `operate_type` tinyint(4) NOT NULL COMMENT '操作类型：1=收入（加分），2=支出（扣分）',
  `source_type` tinyint(4) NOT NULL COMMENT '参与场景：1=每日打卡，2=连续打卡奖励，3=兑换商品消耗，4=HR手动退还积分',
  `points` int(11) NOT NULL COMMENT '本次波动的分值（绝对值）',
  `reference_id` bigint(20) DEFAULT NULL COMMENT '业务关联ID（如打卡记录ID、兑换订单ID）',
  `remark` varchar(255) DEFAULT NULL COMMENT '波动说明',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '发生时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_reference_id` (`reference_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='积分流水表';
