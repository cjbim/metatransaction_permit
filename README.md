# metatransaction_permit
web3 py 를 사용하여 permit서명을 추출하고 서명값으로 수수료대납 트랜잭션 구성하기<br>
permit을 import해서 배포할때 꼭 컨트랙트 이름을 퍼밋에 같이 넣어주고 배포를 해야한다 안그러면 domain을 못찾아서 permit기능을 사용할 수 없다<br>
single_meta_tran은 하나의 토큰을 보낼때 수수료를 보내는 토큰을 수수료로 지불하는 것이다 그러므로 사인 할때 amount를 amount+fee값을 사인해야한다 <br>
multi_meta_tran은 하나의 토큰을 보낼때 다른토큰을 수수료로 지불하는 것이다 사인값을 따로 따로 추출해서 파라미터로 넣어줘야한다. (수수료가 매우비싸므로 비추) <br>
