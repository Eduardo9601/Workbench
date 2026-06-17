UPDATE uc u
   SET (email) = (SELECT b.email
                  FROM backup b
                  WHERE u.idconsumidor = b.idconsumidor)
WHERE EXISTS (
    SELECT 1
      FROM backup b2
     WHERE u.idconsumidor = b2.idconsumidor)

=====================

/* AMBIENTE DE TESTE: Tabelas temporárias para testar o script */
create global temporary table tmp_uc
(   
    idconsumidor int,
    email varchar2(100)
)
on commit preserve rows;

create global temporary table tmp_backup
(   
    idconsumidor int,
    email varchar2(100)
)
on commit preserve rows;

--Dados para teste
insert into tmp_uc (idconsumidor, email) values (1, 'AAAAA@uc');
insert into tmp_uc (idconsumidor, email) values (2, 'BBBBB@uc');
insert into tmp_uc (idconsumidor, email) values (3, 'CCCCC@uc');
insert into tmp_uc (idconsumidor, email) values (4, 'DDDDD@uc');
insert into tmp_uc (idconsumidor, email) values (5, 'EEEEE@uc');
insert into tmp_uc (idconsumidor, email) values (6, 'FFFFF@uc');
insert into tmp_uc (idconsumidor, email) values (7, 'GGGGG@uc');
insert into tmp_uc (idconsumidor, email) values (8, 'HHHHH@uc');
insert into tmp_uc (idconsumidor, email) values (9, 'IIIII@uc');

insert into tmp_backup (idconsumidor, email) values (1, 'AAAAA@bkp');
insert into tmp_backup (idconsumidor, email) values (2, 'BBBBB@bkp');
insert into tmp_backup (idconsumidor, email) values (3, 'CCCCC@bkp');
insert into tmp_backup (idconsumidor, email) values (4, 'DDDDD@bkp');
insert into tmp_backup (idconsumidor, email) values (5, 'EEEEE@bkp');
insert into tmp_backup (idconsumidor, email) values (6, 'FFFFF@bkp');
insert into tmp_backup (idconsumidor, email) values (7, 'GGGGG@bkp');

/* Atualização dos e-mails na tabela temporária tmp_uc para fins de teste */
update 
(   select
            u.email as email_U,
            bk.email as email_BK
    from tmp_uc u
    inner join tmp_backup bk on u.idconsumidor = bk.idconsumidor
    --where (...)
) t
set t.email_U = t.email_BK

select * from tmp_uc;

commit;

/*
idconsumidor   email
    1          AAAAA@bkp
    2          BBBBB@bkp
    3          CCCCC@bkp
    4          DDDDD@bkp
    5          EEEEE@bkp
    6          FFFFF@bkp
    7          GGGGG@bkp
    8          HHHHH@uc
    9          IIIII@uc
*/


============================================

-- Atualização dos dados na tabela física
    update 
    (   select
            u.email as email_U,
            bk.email as email_BK
        from UC u
        inner join backup bk on u.idconsumidor = bk.idconsumidor
        --where (...)
    ) t
    set t.email_U = t.email_BK

    commit;


=========================


update uc 
set uc.email = backup.email
from backup
where uc.idconsumidor =  backup.idconsumidor;

commit;

====================

BEGIN
  FOR rec IN (SELECT bk.email
                    ,uc.id_consumidor
                FROM uc
                    ,backup bk
               WHERE uc.idconsumidor = bk.idconsumidor)
  LOOP
    UPDATE uc
       SET uc.email = rec.email
     WHERE uc.idconsumidor = rec.id_consumidor;
  END LOOP;
END;











