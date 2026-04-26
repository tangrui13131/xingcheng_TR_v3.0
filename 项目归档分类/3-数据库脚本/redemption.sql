-- ----------------------------
-- 0、给 sys_user 新增积分余额字段
-- ----------------------------
ALTER TABLE sys_user ADD COLUMN points INT DEFAULT 500 COMMENT '积分余额' AFTER pwd_update_date;

-- 根据已有流水修正已有用户的积分余额（默认500 + 已有流水净额）
UPDATE sys_user u
LEFT JOIN (SELECT user_id, SUM(points) AS total FROM sys_points_log GROUP BY user_id) p ON u.user_id = p.user_id
SET u.points = 500 + COALESCE(p.total, 0);

-- ----------------------------
-- 1、积分兑换订单表
-- ----------------------------
DROP TABLE IF EXISTS sys_redemption;
CREATE TABLE sys_redemption (
  id            BIGINT(20)    NOT NULL AUTO_INCREMENT COMMENT '兑换订单ID',
  user_id       BIGINT(20)    NOT NULL                COMMENT '申请人ID',
  product_name  VARCHAR(255)  NOT NULL                COMMENT '商品名称',
  points_cost   INT(11)       NOT NULL                COMMENT '消耗积分',
  status        CHAR(1)       DEFAULT '0'             COMMENT '审核状态（0待审核 1已通过 2已驳回）',
  apply_time    DATETIME      DEFAULT CURRENT_TIMESTAMP COMMENT '申请时间',
  audit_time    DATETIME      DEFAULT NULL            COMMENT '审核时间',
  auditor_id    BIGINT(20)    DEFAULT NULL            COMMENT '审核人ID',
  reject_reason VARCHAR(500)  DEFAULT NULL            COMMENT '驳回原因',
  remark        VARCHAR(255)  DEFAULT NULL            COMMENT '备注',
  PRIMARY KEY (id),
  KEY idx_user_id (user_id),
  KEY idx_status (status)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='积分兑换订单表';


-- ----------------------------
-- 兑换审核菜单项（挂在 hrHealthDashboard 父菜单下，parent_id=2008）
-- 字段顺序：menu_id, menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark
-- ----------------------------

-- 兑换审核菜单（C类型）
insert into sys_menu values('2009', '兑换审核', '2008', '2', 'redemptionAudit', 'hr/RedemptionAudit', '', '', 1, 0, 'C', '0', '0', 'hr:redemption:list', 'money', 'admin', sysdate(), '', null, '积分兑换审核菜单');

-- 兑换审核按钮权限（F类型，挂在2009下）
insert into sys_menu values('2010', '审核通过', '2009', '1', '', '', '', '', 1, 0, 'F', '0', '0', 'hr:redemption:audit', '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('2011', '导出记录', '2009', '2', '', '', '', '', 1, 0, 'F', '0', '0', 'hr:redemption:export', '#', 'admin', sysdate(), '', null, '');

-- 将以上菜单授权给 admin 角色（role_id=1）
insert into sys_role_menu values ('1', '2009');
insert into sys_role_menu values ('1', '2010');
insert into sys_role_menu values ('1', '2011');

-- ----------------------------
-- 积分管理菜单（挂在 hr健康管理 父菜单下，parent_id=2008）
-- ----------------------------

-- 积分管理菜单（C类型）
insert into sys_menu values('2012', '积分管理', '2008', '4', 'pointsManage', 'hr/PointsManage', '', '', 1, 0, 'C', '0', '0', 'hr:points:list', 'money', 'admin', sysdate(), '', null, '员工积分管理');

-- 增加积分按钮权限（F类型，挂在2012下）
insert into sys_menu values('2013', '增加积分', '2012', '1', '', '', '', '', 1, 0, 'F', '0', '0', 'hr:points:add', '#', 'admin', sysdate(), '', null, '');

-- 将积分管理菜单授权给 admin 角色（role_id=1）
insert into sys_role_menu values ('1', '2012');
insert into sys_role_menu values ('1', '2013');
