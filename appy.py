from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS
from werkzeug.security import generate_password_hash, check_password_hash
import os

app = Flask(__name__)
CORS(app)

# CONFIGURAÇÃO DO BANCO (ajuste usuário/senha/host se precisar)
app.config["SQLALCHEMY_DATABASE_URI"] = "mysql+pymysql://root:senha@localhost/semeia_coding"
app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False

db = SQLAlchemy(app)

# -------------------------------------------------------------------
# MODELOS (mapeando as tabelas do semeia_coding)
# -------------------------------------------------------------------

class Usuario(db.Model):
    __tablename__ = "usuario"
    id_usuario = db.Column(db.BigInteger, primary_key=True)
    nome = db.Column(db.String(120), nullable=False)
    email_login = db.Column(db.String(160), nullable=False, unique=True)
    senha_hash = db.Column(db.String(255), nullable=False)
    ativo = db.Column(db.Boolean, nullable=False, default=True)
    papel_usuario = db.Column(db.Enum("GESTOR", "OPERADOR_ARMAZEM", "AGENTE_DISTRIBUICAO", "CIDADAO"), nullable=False)
    area_respons = db.Column(db.String(160))
    cargo = db.Column(db.String(120))


class Municipio(db.Model):
    __tablename__ = "municipio"
    id_municipio = db.Column(db.BigInteger, primary_key=True)
    nome = db.Column(db.String(120), nullable=False)
    uf = db.Column(db.String(2), nullable=False)


class Armazem(db.Model):
    __tablename__ = "armazem"
    id_armazem = db.Column(db.BigInteger, primary_key=True)
    nome_armazem = db.Column(db.String(160), nullable=False)
    id_municipio = db.Column(db.BigInteger, db.ForeignKey("municipio.id_municipio"), nullable=False)
    logradouro = db.Column(db.String(180), nullable=False)
    numero = db.Column(db.String(20))
    bairro = db.Column(db.String(120))
    cep = db.Column(db.String(12))
    cidade = db.Column(db.String(120), nullable=False)
    uf = db.Column(db.String(2), nullable=False)


class Fornecedor(db.Model):
    __tablename__ = "fornecedor"
    id_fornecedor = db.Column(db.BigInteger, primary_key=True)
    razao_social = db.Column(db.String(160), nullable=False)
    cnpj = db.Column(db.String(20), nullable=False, unique=True)
    email = db.Column(db.String(160))
    telefone = db.Column(db.String(30))
    logradouro = db.Column(db.String(180), nullable=False)
    cidade = db.Column(db.String(120), nullable=False)
    uf = db.Column(db.String(2), nullable=False)


class Especie(db.Model):
    __tablename__ = "especie"
    id_especie = db.Column(db.BigInteger, primary_key=True)
    nome_comum = db.Column(db.String(120), nullable=False)
    nome_cientifico = db.Column(db.String(160))


class Lote(db.Model):
    __tablename__ = "lote"
    id_lote = db.Column(db.BigInteger, primary_key=True)
    numero_lote = db.Column(db.String(80), nullable=False, unique=True)
    id_especie = db.Column(db.BigInteger, db.ForeignKey("especie.id_especie"), nullable=False)
    id_fornecedor = db.Column(db.BigInteger, db.ForeignKey("fornecedor.id_fornecedor"), nullable=False)
    validade = db.Column(db.Date)
    qtd_sacas = db.Column(db.Integer, nullable=False)
    qr_code = db.Column(db.String(200))


class OrdemExpedicao(db.Model):
    __tablename__ = "ordem_expedicao"
    id_expedicao = db.Column(db.BigInteger, primary_key=True)
    id_municipio = db.Column(db.BigInteger, db.ForeignKey("municipio.id_municipio"), nullable=False)
    data_prevista = db.Column(db.Date, nullable=False)
    status = db.Column(db.Enum("PLANEJADA", "EXPEDIDA", "CONCLUIDA", "CANCELADA"), nullable=False, default="PLANEJADA")
    id_gestor_resp = db.Column(db.BigInteger, db.ForeignKey("usuario.id_usuario"))


class MovimentoEstoque(db.Model):
    __tablename__ = "movimento_estoque"
    id_mov = db.Column(db.BigInteger, primary_key=True)
    tipo = db.Column(db.Enum("ENTRADA", "SAIDA", "TRANSFERENCIA"), nullable=False)
    id_lote = db.Column(db.BigInteger, db.ForeignKey("lote.id_lote"), nullable=False)
    id_armazem_origem = db.Column(db.BigInteger, db.ForeignKey("armazem.id_armazem"))
    id_armazem_destino = db.Column(db.BigInteger, db.ForeignKey("armazem.id_armazem"))
    quant_sacas = db.Column(db.Integer, nullable=False)
    data_mov = db.Column(db.DateTime, nullable=False)
    id_usuario = db.Column(db.BigInteger, db.ForeignKey("usuario.id_usuario"), nullable=False)
    id_ordem_expedicao = db.Column(db.BigInteger, db.ForeignKey("ordem_expedicao.id_expedicao"))

# -------------------------------------------------------------------
# HELPER: transformar modelos em dict
# -------------------------------------------------------------------

def to_dict(obj):
    return {c.name: getattr(obj, c.name) for c in obj.__table__.columns}

# -------------------------------------------------------------------
# ROTAS DE AUTENTICAÇÃO (compatíveis com teu front atual)
# -------------------------------------------------------------------

@app.route("/api/cadastrar-usuario", methods=["POST"])
def cadastrar_usuario():
    data = request.get_json()
    try:
        nome = data.get("nome")
        email = data.get("email")
        senha = data.get("senha")
        papel_usuario = data.get("papel_usuario")
        area_respons = data.get("area_respons")
        cargo = data.get("cargo")

        if not all([nome, email, senha, papel_usuario]):
            return jsonify({"success": False, "message": "Campos obrigatórios ausentes."}), 400

        if Usuario.query.filter_by(email_login=email).first():
            return jsonify({"success": False, "message": "E-mail já cadastrado."}), 400

        senha_hash = generate_password_hash(senha)

        usuario = Usuario(
            nome=nome,
            email_login=email,
            senha_hash=senha_hash,
            papel_usuario=papel_usuario,
            ativo=True,
            area_respons=area_respons,
            cargo=cargo
        )
        db.session.add(usuario)
        db.session.commit()

        return jsonify({"success": True, "message": "Usuário cadastrado com sucesso.", "data": to_dict(usuario)}), 201
    except Exception as e:
        db.session.rollback()
        return jsonify({"success": False, "message": str(e)}), 500


@app.route("/api/login", methods=["POST"])
def login():
    data = request.get_json()
    email = data.get("email")
    senha = data.get("senha")

    user = Usuario.query.filter_by(email_login=email, ativo=True).first()
    if not user or not check_password_hash(user.senha_hash, senha):
        return jsonify({"success": False, "message": "Credenciais inválidas."}), 401

    # aqui você poderia gerar token se quisesse
    return jsonify({
        "success": True,
        "message": "Login realizado com sucesso.",
        "user": {
            "id_usuario": user.id_usuario,
            "nome": user.nome,
            "email": user.email_login,
            "papel_usuario": user.papel_usuario
        }
    }), 200

# -------------------------------------------------------------------
# CRUD GENÉRICO POR TABELA
# (POST / GET / GET by ID / PUT / DELETE)
# -------------------------------------------------------------------
# USUARIOS
@app.route("/api/usuarios", methods=["GET"])
def listar_usuarios():
    usuarios = Usuario.query.all()
    return jsonify([to_dict(u) for u in usuarios])


@app.route("/api/usuarios/<int:id_usuario>", methods=["GET"])
def obter_usuario(id_usuario):
    usuario = Usuario.query.get_or_404(id_usuario)
    return jsonify(to_dict(usuario))


@app.route("/api/usuarios", methods=["POST"])
def criar_usuario():
    data = request.get_json()
    try:
        senha = data.get("senha")
        senha_hash = generate_password_hash(senha) if senha else None

        usuario = Usuario(
            nome=data.get("nome"),
            email_login=data.get("email_login"),
            senha_hash=senha_hash,
            ativo=data.get("ativo", True),
            papel_usuario=data.get("papel_usuario"),
            area_respons=data.get("area_respons"),
            cargo=data.get("cargo")
        )
        db.session.add(usuario)
        db.session.commit()
        return jsonify({"success": True, "data": to_dict(usuario)}), 201
    except Exception as e:
        db.session.rollback()
        return jsonify({"success": False, "message": str(e)}), 500


@app.route("/api/usuarios/<int:id_usuario>", methods=["PUT"])
def atualizar_usuario(id_usuario):
    usuario = Usuario.query.get_or_404(id_usuario)
    data = request.get_json()

    try:
        usuario.nome = data.get("nome", usuario.nome)
        usuario.email_login = data.get("email_login", usuario.email_login)
        usuario.papel_usuario = data.get("papel_usuario", usuario.papel_usuario)
        usuario.ativo = data.get("ativo", usuario.ativo)
        usuario.area_respons = data.get("area_respons", usuario.area_respons)
        usuario.cargo = data.get("cargo", usuario.cargo)

        if "senha" in data and data["senha"]:
            usuario.senha_hash = generate_password_hash(data["senha"])

        db.session.commit()
        return jsonify({"success": True, "data": to_dict(usuario)})
    except Exception as e:
        db.session.rollback()
        return jsonify({"success": False, "message": str(e)}), 500


@app.route("/api/usuarios/<int:id_usuario>", methods=["DELETE"])
def deletar_usuario(id_usuario):
    usuario = Usuario.query.get_or_404(id_usuario)
    try:
        db.session.delete(usuario)
        db.session.commit()
        return jsonify({"success": True, "message": "Usuário removido."})
    except Exception as e:
        db.session.rollback()
        return jsonify({"success": False, "message": str(e)}), 500


# MUNICIPIOS
@app.route("/api/municipios", methods=["GET"])
def listar_municipios():
    municipios = Municipio.query.all()
    return jsonify([to_dict(m) for m in municipios])


@app.route("/api/municipios/<int:id_municipio>", methods=["GET"])
def obter_municipio(id_municipio):
    municipio = Municipio.query.get_or_404(id_municipio)
    return jsonify(to_dict(municipio))


@app.route("/api/municipios", methods=["POST"])
def criar_municipio():
    data = request.get_json()
    try:
        municipio = Municipio(
            nome=data.get("nome"),
            uf=data.get("uf")
        )
        db.session.add(municipio)
        db.session.commit()
        return jsonify({"success": True, "data": to_dict(municipio)}), 201
    except Exception as e:
        db.session.rollback()
        return jsonify({"success": False, "message": str(e)}), 500


@app.route("/api/municipios/<int:id_municipio>", methods=["PUT"])
def atualizar_municipio(id_municipio):
    municipio = Municipio.query.get_or_404(id_municipio)
    data = request.get_json()
    try:
        municipio.nome = data.get("nome", municipio.nome)
        municipio.uf = data.get("uf", municipio.uf)
        db.session.commit()
        return jsonify({"success": True, "data": to_dict(municipio)})
    except Exception as e:
        db.session.rollback()
        return jsonify({"success": False, "message": str(e)}), 500


@app.route("/api/municipios/<int:id_municipio>", methods=["DELETE"])
def deletar_municipio(id_municipio):
    municipio = Municipio.query.get_or_404(id_municipio)
    try:
        db.session.delete(municipio)
        db.session.commit()
        return jsonify({"success": True, "message": "Município removido."})
    except Exception as e:
        db.session.rollback()
        return jsonify({"success": False, "message": str(e)}), 500


# ARMAZENS
@app.route("/api/armazens", methods=["GET"])
def listar_armazens():
    armazens = Armazem.query.all()
    return jsonify([to_dict(a) for a in armazens])


@app.route("/api/armazens/<int:id_armazem>", methods=["GET"])
def obter_armazem(id_armazem):
    armazem = Armazem.query.get_or_404(id_armazem)
    return jsonify(to_dict(armazem))


@app.route("/api/armazens", methods=["POST"])
def criar_armazem():
    data = request.get_json()
    try:
        armazem = Armazem(
            nome_armazem=data.get("nome_armazem"),
            id_municipio=data.get("id_municipio"),
            logradouro=data.get("logradouro"),
            numero=data.get("numero"),
            bairro=data.get("bairro"),
            cep=data.get("cep"),
            cidade=data.get("cidade"),
            uf=data.get("uf")
        )
        db.session.add(armazem)
        db.session.commit()
        return jsonify({"success": True, "data": to_dict(armazem)}), 201
    except Exception as e:
        db.session.rollback()
        return jsonify({"success": False, "message": str(e)}), 500


@app.route("/api/armazens/<int:id_armazem>", methods=["PUT"])
def atualizar_armazem(id_armazem):
    armazem = Armazem.query.get_or_404(id_armazem)
    data = request.get_json()
    try:
        armazem.nome_armazem = data.get("nome_armazem", armazem.nome_armazem)
        armazem.id_municipio = data.get("id_municipio", armazem.id_municipio)
        armazem.logradouro = data.get("logradouro", armazem.logradouro)
        armazem.numero = data.get("numero", armazem.numero)
        armazem.bairro = data.get("bairro", armazem.bairro)
        armazem.cep = data.get("cep", armazem.cep)
        armazem.cidade = data.get("cidade", armazem.cidade)
        armazem.uf = data.get("uf", armazem.uf)
        db.session.commit()
        return jsonify({"success": True, "data": to_dict(armazem)})
    except Exception as e:
        db.session.rollback()
        return jsonify({"success": False, "message": str(e)}), 500


@app.route("/api/armazens/<int:id_armazem>", methods=["DELETE"])
def deletar_armazem(id_armazem):
    armazem = Armazem.query.get_or_404(id_armazem)
    try:
        db.session.delete(armazem)
        db.session.commit()
        return jsonify({"success": True, "message": "Armazém removido."})
    except Exception as e:
        db.session.rollback()
        return jsonify({"success": False, "message": str(e)}), 500


# FORNECEDORES
@app.route("/api/fornecedores", methods=["GET"])
def listar_fornecedores():
    fornecedores = Fornecedor.query.all()
    return jsonify([to_dict(f) for f in fornecedores])


@app.route("/api/fornecedores/<int:id_fornecedor>", methods=["GET"])
def obter_fornecedor(id_fornecedor):
    fornecedor = Fornecedor.query.get_or_404(id_fornecedor)
    return jsonify(to_dict(fornecedor))


@app.route("/api/fornecedores", methods=["POST"])
def criar_fornecedor():
    data = request.get_json()
    try:
        fornecedor = Fornecedor(
            razao_social=data.get("razao_social"),
            cnpj=data.get("cnpj"),
            email=data.get("email"),
            telefone=data.get("telefone"),
            logradouro=data.get("logradouro"),
            cidade=data.get("cidade"),
            uf=data.get("uf")
        )
        db.session.add(fornecedor)
        db.session.commit()
        return jsonify({"success": True, "data": to_dict(fornecedor)}), 201
    except Exception as e:
        db.session.rollback()
        return jsonify({"success": False, "message": str(e)}), 500


@app.route("/api/fornecedores/<int:id_fornecedor>", methods=["PUT"])
def atualizar_fornecedor(id_fornecedor):
    fornecedor = Fornecedor.query.get_or_404(id_fornecedor)
    data = request.get_json()
    try:
        fornecedor.razao_social = data.get("razao_social", fornecedor.razao_social)
        fornecedor.cnpj = data.get("cnpj", fornecedor.cnpj)
        fornecedor.email = data.get("email", fornecedor.email)
        fornecedor.telefone = data.get("telefone", fornecedor.telefone)
        fornecedor.logradouro = data.get("logradouro", fornecedor.logradouro)
        fornecedor.cidade = data.get("cidade", fornecedor.cidade)
        fornecedor.uf = data.get("uf", fornecedor.uf)
        db.session.commit()
        return jsonify({"success": True, "data": to_dict(fornecedor)})
    except Exception as e:
        db.session.rollback()
        return jsonify({"success": False, "message": str(e)}), 500


@app.route("/api/fornecedores/<int:id_fornecedor>", methods=["DELETE"])
def deletar_fornecedor(id_fornecedor):
    fornecedor = Fornecedor.query.get_or_404(id_fornecedor)
    try:
        db.session.delete(fornecedor)
        db.session.commit()
        return jsonify({"success": True, "message": "Fornecedor removido."})
    except Exception as e:
        db.session.rollback()
        return jsonify({"success": False, "message": str(e)}), 500


# ESPECIES
@app.route("/api/especies", methods=["GET"])
def listar_especies():
    especies = Especie.query.all()
    return jsonify([to_dict(e) for e in especies])


@app.route("/api/especies/<int:id_especie>", methods=["GET"])
def obter_especie(id_especie):
    especie = Especie.query.get_or_404(id_especie)
    return jsonify(to_dict(especie))


@app.route("/api/especies", methods=["POST"])
def criar_especie():
    data = request.get_json()
    try:
        especie = Especie(
            nome_comum=data.get("nome_comum"),
            nome_cientifico=data.get("nome_cientifico")
        )
        db.session.add(especie)
        db.session.commit()
        return jsonify({"success": True, "data": to_dict(especie)}), 201
    except Exception as e:
        db.session.rollback()
        return jsonify({"success": False, "message": str(e)}), 500


@app.route("/api/especies/<int:id_especie>", methods=["PUT"])
def atualizar_especie(id_especie):
    especie = Especie.query.get_or_404(id_especie)
    data = request.get_json()
    try:
        especie.nome_comum = data.get("nome_comum", especie.nome_comum)
        especie.nome_cientifico = data.get("nome_cientifico", especie.nome_cientifico)
        db.session.commit()
        return jsonify({"success": True, "data": to_dict(especie)})
    except Exception as e:
        db.session.rollback()
        return jsonify({"success": False, "message": str(e)}), 500


@app.route("/api/especies/<int:id_especie>", methods=["DELETE"])
def deletar_especie(id_especie):
    especie = Especie.query.get_or_404(id_especie)
    try:
        db.session.delete(especie)
        db.session.commit()
        return jsonify({"success": True, "message": "Espécie removida."})
    except Exception as e:
        db.session.rollback()
        return jsonify({"success": False, "message": str(e)}), 500


# LOTES
@app.route("/api/lotes", methods=["GET"])
def listar_lotes():
    lotes = Lote.query.all()
    return jsonify([to_dict(l) for l in lotes])


@app.route("/api/lotes/<int:id_lote>", methods=["GET"])
def obter_lote(id_lote):
    lote = Lote.query.get_or_404(id_lote)
    return jsonify(to_dict(lote))


@app.route("/api/lotes", methods=["POST"])
def criar_lote():
    data = request.get_json()
    try:
        lote = Lote(
            numero_lote=data.get("numero_lote"),
            id_especie=data.get("id_especie"),
            id_fornecedor=data.get("id_fornecedor"),
            validade=data.get("validade"),  # ideal converter string -> date
            qtd_sacas=data.get("qtd_sacas"),
            qr_code=data.get("qr_code")
        )
        db.session.add(lote)
        db.session.commit()
        return jsonify({"success": True, "data": to_dict(lote)}), 201
    except Exception as e:
        db.session.rollback()
        return jsonify({"success": False, "message": str(e)}), 500


@app.route("/api/lotes/<int:id_lote>", methods=["PUT"])
def atualizar_lote(id_lote):
    lote = Lote.query.get_or_404(id_lote)
    data = request.get_json()
    try:
        lote.numero_lote = data.get("numero_lote", lote.numero_lote)
        lote.id_especie = data.get("id_especie", lote.id_especie)
        lote.id_fornecedor = data.get("id_fornecedor", lote.id_fornecedor)
        lote.validade = data.get("validade", lote.validade)
        lote.qtd_sacas = data.get("qtd_sacas", lote.qtd_sacas)
        lote.qr_code = data.get("qr_code", lote.qr_code)
        db.session.commit()
        return jsonify({"success": True, "data": to_dict(lote)})
    except Exception as e:
        db.session.rollback()
        return jsonify({"success": False, "message": str(e)}), 500


@app.route("/api/lotes/<int:id_lote>", methods=["DELETE"])
def deletar_lote(id_lote):
    lote = Lote.query.get_or_404(id_lote)
    try:
        db.session.delete(lote)
        db.session.commit()
        return jsonify({"success": True, "message": "Lote removido."})
    except Exception as e:
        db.session.rollback()
        return jsonify({"success": False, "message": str(e)}), 500


# ORDEM_EXPEDICAO
@app.route("/api/ordens_expedicao", methods=["GET"])
def listar_ordens_expedicao():
    ordens = OrdemExpedicao.query.all()
    return jsonify([to_dict(o) for o in ordens])


@app.route("/api/ordens_expedicao/<int:id_expedicao>", methods=["GET"])
def obter_ordem_expedicao(id_expedicao):
    ordem = OrdemExpedicao.query.get_or_404(id_expedicao)
    return jsonify(to_dict(ordem))


@app.route("/api/ordens_expedicao", methods=["POST"])
def criar_ordem_expedicao():
    data = request.get_json()
    try:
        ordem = OrdemExpedicao(
            id_municipio=data.get("id_municipio"),
            data_prevista=data.get("data_prevista"),  # string -> date idealmente
            status=data.get("status", "PLANEJADA"),
            id_gestor_resp=data.get("id_gestor_resp")
        )
        db.session.add(ordem)
        db.session.commit()
        return jsonify({"success": True, "data": to_dict(ordem)}), 201
    except Exception as e:
        db.session.rollback()
        return jsonify({"success": False, "message": str(e)}), 500


@app.route("/api/ordens_expedicao/<int:id_expedicao>", methods=["PUT"])
def atualizar_ordem_expedicao(id_expedicao):
    ordem = OrdemExpedicao.query.get_or_404(id_expedicao)
    data = request.get_json()
    try:
        ordem.id_municipio = data.get("id_municipio", ordem.id_municipio)
        ordem.data_prevista = data.get("data_prevista", ordem.data_prevista)
        ordem.status = data.get("status", ordem.status)
        ordem.id_gestor_resp = data.get("id_gestor_resp", ordem.id_gestor_resp)
        db.session.commit()
        return jsonify({"success": True, "data": to_dict(ordem)})
    except Exception as e:
        db.session.rollback()
        return jsonify({"success": False, "message": str(e)}), 500


@app.route("/api/ordens_expedicao/<int:id_expedicao>", methods=["DELETE"])
def deletar_ordem_expedicao(id_expedicao):
    ordem = OrdemExpedicao.query.get_or_404(id_expedicao)
    try:
        db.session.delete(ordem)
        db.session.commit()
        return jsonify({"success": True, "message": "Ordem de expedição removida."})
    except Exception as e:
        db.session.rollback()
        return jsonify({"success": False, "message": str(e)}), 500


# MOVIMENTO_ESTOQUE
@app.route("/api/movimentos_estoque", methods=["GET"])
def listar_movimentos_estoque():
    movs = MovimentoEstoque.query.all()
    return jsonify([to_dict(m) for m in movs])


@app.route("/api/movimentos_estoque/<int:id_mov>", methods=["GET"])
def obter_movimento_estoque(id_mov):
    mov = MovimentoEstoque.query.get_or_404(id_mov)
    return jsonify(to_dict(mov))


@app.route("/api/movimentos_estoque", methods=["POST"])
def criar_movimento_estoque():
    data = request.get_json()
    try:
        mov = MovimentoEstoque(
            tipo=data.get("tipo"),
            id_lote=data.get("id_lote"),
            id_armazem_origem=data.get("id_armazem_origem"),
            id_armazem_destino=data.get("id_armazem_destino"),
            quant_sacas=data.get("quant_sacas"),
            data_mov=data.get("data_mov"),  # string -> datetime idealmente
            id_usuario=data.get("id_usuario"),
            id_ordem_expedicao=data.get("id_ordem_expedicao")
        )
        db.session.add(mov)
        db.session.commit()
        return jsonify({"success": True, "data": to_dict(mov)}), 201
    except Exception as e:
        db.session.rollback()
        return jsonify({"success": False, "message": str(e)}), 500


@app.route("/api/movimentos_estoque/<int:id_mov>", methods=["PUT"])
def atualizar_movimento_estoque(id_mov):
    mov = MovimentoEstoque.query.get_or_404(id_mov)
    data = request.get_json()
    try:
        mov.tipo = data.get("tipo", mov.tipo)
        mov.id_lote = data.get("id_lote", mov.id_lote)
        mov.id_armazem_origem = data.get("id_armazem_origem", mov.id_armazem_origem)
        mov.id_armazem_destino = data.get("id_armazem_destino", mov.id_armazem_destino)
        mov.quant_sacas = data.get("quant_sacas", mov.quant_sacas)
        mov.data_mov = data.get("data_mov", mov.data_mov)
        mov.id_usuario = data.get("id_usuario", mov.id_usuario)
        mov.id_ordem_expedicao = data.get("id_ordem_expedicao", mov.id_ordem_expedicao)
        db.session.commit()
        return jsonify({"success": True, "data": to_dict(mov)})
    except Exception as e:
        db.session.rollback()
        return jsonify({"success": False, "message": str(e)}), 500


@app.route("/api/movimentos_estoque/<int:id_mov>", methods=["DELETE"])
def deletar_movimento_estoque(id_mov):
    mov = MovimentoEstoque.query.get_or_404(id_mov)
    try:
        db.session.delete(mov)
        db.session.commit()
        return jsonify({"success": True, "message": "Movimento de estoque removido."})
    except Exception as e:
        db.session.rollback()
        return jsonify({"success": False, "message": str(e)}), 500


# -------------------------------------------------------------------
# MAIN
# -------------------------------------------------------------------
if __name__ == "__main__":
    # db.create_all()  # só use se as tabelas ainda não existirem
    app.run(host="0.0.0.0", port=5500, debug=True)
